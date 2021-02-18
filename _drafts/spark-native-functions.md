---
layout: post
title: Writing Spark Native Functions
tags: [spark, scala, big data]
---

Recently Matthew Powers released a short
[blog post](https://neapowers.com/apache-spark/native-functions-catalyst-expressions/)
on creating Spark native functions that I found interesting.
Previously I had read 
[a post by Simeon Simeonov](https://neapowers.com/apache-spark/native-functions-catalyst-expressions/)
about the same topic but had not internalised the concepts presented.

Powers' post shows a simple example of creating a Catalyst Expression, the
proper name for a Spark Native Function, using the example of creating a method
to get the beginning of the month. This involves writing code in several Spark
packages. Presumably this is done due to some reflective requirements.

I thought I'd attempt something similar to eliminate the UDF I mentioned in a
[previous post]({% post_url 2019-11-22-creating-date-range-spark %})
on getting all the dates between 2 dates (inclusively in this
case), for a more in-depth guide please refer to Powers' post.

The first thing I did was create an object to hold my additional functions.  
I placed this in `org.apache.spark.sql`, however I am unsure if this is
necessary:

```scala
object LyndonFunctions {

  private def withExpr(expr: Expression): Column = Column(expr)

  def dates_between(start: Column, end: Column): Column =
    withExpr {
      DatesBetween(start.expr, end.expr)
    }

}
```

The `DatesBetween` is a case class defined in
`org.apache.spark.sql.catalyst.expressions`, and is the core part of writing new
Spark Native Functions as it extends the `Expression` type:

```scala
case class DatesBetween(
    startDate: Expression,
    endDate: Expression
) extends BinaryExpression
    with ImplicitCastInputTypes {
  override def prettyName: String = "dates_between"

  override def left: Expression  = startDate
  override def right: Expression = endDate

  override def inputTypes: Seq[AbstractDataType] = Seq(DateType, DateType)

  override def dataType: DataType = ArrayType(DateType, containsNull = false)

  override protected def nullSafeEval(start: Any, end: Any): Any =
    LyndonUtils.getDatesBetween(start.asInstanceOf[Int], end.asInstanceOf[Int])

  override protected def doGenCode(
      ctx: CodegenContext,
      ev: ExprCode
  ): ExprCode = {
    val dtu = LyndonUtils.getClass.getName.stripSuffix("$")
    defineCodeGen(
      ctx,
      ev,
      (a, b) => s"$dtu.getDatesBetween($a,$b)"
    )
  }
}
```

I still need to familiarise myself further with the `Expression` class and it's
subtypes but the 2 most important parts in my example are the `nullSafeEval` and
`doGenCode` methods.  
Both define what code is called by this expression. `nullSafeEval` calls actual
code while `doGenCode` generates Java code that will be compiled that uses the
given code. In this case I have put the Expression code in the function
`getDatesBetween` defined in `LyndonUtils` which I placed in
`org.apache.spark.sql.catalyst.util`.

```scala
object LyndonUtils {

  type SQLDate = Int

  private[this] def localDate(date: SQLDate): LocalDate =
    LocalDate.ofEpochDay(date)

  private[this] def localDateToDays(localDate: LocalDate): SQLDate =
    Math.toIntExact(localDate.toEpochDay)

  def getDatesBetween(start: SQLDate, end: SQLDate): ArrayData = {
    val startDate = localDate(start)
    val daysBetween = Duration
      .between(
        startDate.atStartOfDay(),
        localDate(end).atStartOfDay()
      )
      .toDays

    val newRows = Seq.newBuilder[SQLDate]
    // get all intermediate dates
    for (day <- 0L to daysBetween) {
      val date = startDate.plusDays(day)
      newRows += localDateToDays(date)
    }
    toArrayData(newRows.result())
  }
}

```

Note that I use the `Int` type for dates in this code, this is because Spark
stores dates internally as integers. I also return an `ArrayData` type as this
is the type used internally for arrays in Spark.

With this done I can now make use of my function and even see it in the Logical
Plans:

```scala
import spark.implicits._

val df = Seq(
  (Date.valueOf("2020-01-15"), Date.valueOf("2020-01-20")),
  (null, null),
).toDF("start", "end")
  .withColumn("between", dates_between($"start", $"end"))

df.show(false)
df.explain(true)
```

| start      | end        | between                                                                  |
| ---------- | ---------- | ------------------------------------------------------------------------ |
| 2020-01-15 | 2020-01-20 | [2020-01-15, 2020-01-16, 2020-01-17, 2020-01-18, 2020-01-19, 2020-01-20] |
| null       | null       | null                                                                     |

```text
== Parsed Logical Plan ==
'Project [start#7, end#8, dates_between('start, 'end) AS between#11]
+- Project [_1#2 AS start#7, _2#3 AS end#8]
   +- LocalRelation [_1#2, _2#3]

== Analyzed Logical Plan ==
start: date, end: date, between: array<date>
Project [start#7, end#8, dates_between(start#7, end#8) AS between#11]
+- Project [_1#2 AS start#7, _2#3 AS end#8]
   +- LocalRelation [_1#2, _2#3]

== Optimized Logical Plan ==
LocalRelation [start#7, end#8, between#11]

== Physical Plan ==
LocalTableScan [start#7, end#8, between#11]
```

With that done I have eliminated the UDF defined in my 
[previous post]({% post_url 2019-11-22-creating-date-range-spark %}).

As a bonus I can create a simple extension class in Scala to extract all the
densifying described in that post into a single reusable place:

```scala
object ExtraDataFrameFunctions {

  implicit class DataFrameUtils(df: DataFrame) {

    def densify_on_date(
        dateColumn: String,
        ascending: Boolean = true,
        nullsFirst: Boolean = true
    ): DataFrame = {
      import df.sparkSession.implicits._
      val dates = df
        .select(dateColumn)
        .agg(
          min(dateColumn).as("min"),
          max(dateColumn).as("max")
        )
        .withColumn("range", dates_between($"min", $"max"))
        .drop("min", "max")
        .withColumn(dateColumn, explode($"range"))
        .drop("range")

      val sortCol = (ascending, nullsFirst) match {
        case (true, true)   => col(dateColumn).asc_nulls_first
        case (true, false)  => col(dateColumn).asc_nulls_last
        case (false, true)  => col(dateColumn).desc_nulls_first
        case (false, false) => col(dateColumn).desc_nulls_last
      }
      // Must be outer to include any rows with null values in their date column
      df.join(dates, Seq(dateColumn), "outer")
        .sort(sortCol)
    }
  }

}
```
