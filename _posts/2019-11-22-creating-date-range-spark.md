---
layout: post
title: Creating a Date Range in Apache Spark Using Scala
tags: [spark, scala, big data]
---

Sometimes when dealing with data in Spark you may find yourself needing to join
data against a large date range. I have encountered this when needing take a
sparsely populated table (in terms of the dates) and fill in any missing entries
with some sensible value, be it a default value (using the `na` functions) or a
previous dates value (using a windowing function).

Take for example the following example table:

| Date       | Stock   |
| ---------- | ------- |
| 2019-01-01 | 0       |
| 2019-01-12 | 10      |
| 2019-01-14 | 9       |
| 2019-01-15 | 8       |
| 2019-01-20 | 10      |
| 2019-01-25 | 7       |
| 2019-01-31 | 5       |

If we wanted to fill in the gaps in the dates here we'd need a date range
between the minimum and maximum dates within this table:
`2019-01-01` to `2019-01-31`.

Let's represent this in some Spark Scala code to help illustrate:

```scala
val sparseData = spark.sparkContext.parallelize(Seq(
  ("2019-01-01", 0),
  ("2019-01-12", 10),
  ("2019-01-14", 9),
  ("2019-01-15", 8),
  ("2019-01-20", 10),
  ("2019-01-25", 7),
  ("2019-01-31", 5)
)).toDF("date", "stock")
  .withColumn("date", col("date").cast(DateType))

val minMax = sparseData.select("date")
  .agg(min("date").as("min"), max("date").as("max"))
```

That `minMax` DataFrame here will look like:

| min        |        max |
| ---------- | ---------- |
| 2019-01-01 | 2019-01-31 |

Now we want to create a DataFrame containing all the dates between `min` and
`max`, our date range.  
One simple way of doing this is to create a UDF (User Defined Function) that
will produce a collection of dates between 2 values and then make use of the
`explode` function in Spark to create the rows (see the
[functions documentation](https://spark.apache.org/docs/latest/api/scala/index.html#org.apache.spark.sql.functions$)
for details).

The following Scala code will create a sequence of `java.sql.Date` types between
2 dates. Note that I have used the newer `java.time` classes here and converted
between them as I am more comfortable with these classes:

```scala
import java.sql.Date
import java.time.{Duration, LocalDate}

/**
 * Create a sequence containing all dates between from and to
 * @param dateFrom The date from
 * @param dateTo The date to
 * @return A Seq containing all dates in the given range
 */
def getDateRange(
    dateFrom: Date,
    dateTo: Date
): Seq[Date] = {
  val daysBetween = Duration
    .between(
      dateFrom.toLocalDate.atStartOfDay(),
      dateTo.toLocalDate.atStartOfDay()
    )
    .toDays

  val newRows = Seq.newBuilder[Date]
  // get all intermediate dates
  for (day <- 0L to daysBetween) {
    val date = Date.valueOf(dateFrom.toLocalDate.plusDays(day))
    newRows += date
  }
  newRows.result()
}
```

With this function we can create a UDF to use:

```scala
val dateRangeUDF = udf(getDateRange _, ArrayType(DateType))
```

What this UDF will do is create an array column containing all the dates
between within the given range:

```scala
val minMaxWithRange = minMax.withColumn(
  "range",
  dateRangeUDF(col("min"), col("max"))
  )
```

This will look something like this (I have truncated the range column to make
it easier to see):

| min        |        max | range                                              |
| ---------- | ---------- | -------------------------------------------------- |
| 2019-01-01 | 2019-01-31 | 2019-01-01, 2019-01-02, ... 2019-01-30, 2019-01-31 |

Each entry in the range array will also be typed correctly as a date.

With this array we can make use of the built in spark function `explode` to
create rows for us:

```scala
val allDates = minMaxWithRange
  .withColumn("date", explode(col("range")))
  .drop("range", "min", "max")
```

This will produce a DataFrame that looks like the following, with all the dates
between `2019-01-01` and `2019-01-31`:

| date       |
| ---------- |
| 2019-01-01 |
| 2019-01-02 |
| ...        |
| 2019-01-30 |
| 2019-01-31 |

We can then join on this with our original DataFrame:

```scala
val joined = sparseData.join(allDates, Seq("date"), "outer")
  .sort("date")
// A sort might be needed if you want your data to remain ordered by date
```

And proceed to do any filling logic we want for the missing fields.  
For example filling them with 0s:

```scala
joined.na.fill(0, Seq("stock"))
```

Or filling them with previous known values, essentially stretching the data
along to make a dense table:

```scala
import org.apache.spark.sql.expressions.Window

val window = Window
  // Note this windows over all the data as a single partition
  .orderBy("date")
  .rowsBetween(Window.unboundedPreceding, Window.currentRow)
val filled = joined.withColumn(
  "stock",
  when(
    col("stock").isNull,
    last("stock", ignoreNulls = true).over(window)
    )
    .otherwise(col("stock"))
)
```

Hopefully this post is useful to anyone curious about stretching a data set or
creating a date range in Apache Spark using Scala.  
There are likely alternative methods to doing this, especially in Python where
you can potentially make use of external libraries like Pandas to create a range
and then send it to Spark to use.  
You may even be able to use Spark Native functions which would avoid any
potential performance issues with using a UDF.
