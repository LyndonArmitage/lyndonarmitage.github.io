---
layout: post
title: groupBy, groupByKey, and windowing in Spark
tags:
- spark
- scala
- code
- programming
---

Recently at work I encountered a Spark job that had begun to intermittently
fail after a long period of successes. Debugging Spark jobs is a skill in and
of itself that I will touch on it lightly here, but in my evaluation of this
job I found that:

1. The input datasets had grown over time.
2. As a result of the growing datasets, and the shuffling of data, lots of
   tasks were spilling large amounts of data to disk
3. The initial job was set up on a relatively small AWS EMR cluster resulting
   in the driver and single executor co-existing on the same EC2 instance.
4. With the mounting spillage of data to both memory and disk, the EC2 instance
   in question would get knocked out, taking the driver with it.

My first response was to simply resize the cluster using one of our set sizes
of clusters, we went from the following small cluster containing:

| Master   | Workers        |
| -------- + -------------- |
| m5xlarge | 1 x m5.4xlarge |

Which works out to a cluster with 16 vCPUs and 64 GiB of memory on the single
worker node.

To a cluster that looked like this:

| Master   | Workers        |
| -------- + -------------- |
| m5xlarge | 3 x m5.2xlarge |

Which works out to be a cluster with 24 vCPUs and 96 GiB of memory over the 3
workers.

In truth I did this without fully understanding the above 4 points. The new run
of the job started and carried on running past the time the old job failed.
However, after running over twice the normal runtime of the original job (when
it was succeeding) I realised I'd made a mistake.

In changing my worker pool to contain 3 workers, 1 was reserved to act as a
driver within EMR and the other 2 were responsible for the executing the tasks
of the job.

The 2 smaller nodes in this "larger" cluster actually had less memory
individually than the original single node had and as a result were spilling
even more data than before. And, unlike the original, the cluster was not
terminating because the driver remained intact.

With this in mind, I further resized the cluster to the following:

| Master   | Workers        |
| -------- + -------------- |
| m5xlarge | 4 x m5.4xlarge |

This is 4 times the size of the original and successfully solved the
overrunning cluster. It did not however solve the data spillage problem, and
that's because the spillage, it merely masked the issue. This is because the
spillage was caused by the small shuffle size of the job.

This job was using the default of 200 shuffle partitions that comes with Spark.
This shuffle size is adequate for medium sized datasets but falls short for
large datasets and is overkill for many smaller datasets. Thankfully, Spark has
some optimisation for the latter in the form of automatic broadcast joins, and
for the former it introduced
[Adaptive Query Execution](https://spark.apache.org/docs/latest/sql-performance-tuning.html#adaptive-query-execution)
in Spark 3.0.

Adaptive Query Execution (or AQE as some call it), introduced a few features
designed to help alleviate a common problem that plagues Spark job developers,
choosing the right shuffle size. I won't go into the depths of it now, but I
will give a little warning on a potential pitfall with it later in this post.

With the job I was dealing with, simply upping the shuffle size was enough to
alleviate the spillage, the added overhead of extra tasks can however have an
impact on the speed of the job and cause slow-down in earlier stages that don't
need such a large number of shuffle partitions. This is where AQE can help, you
can configure it to use an initially large number of shuffles and Spark will
work out the optimum number to use on the reduce side of the shuffle.
Unfortunately, there is a catch. The initial number you pass to AQE will incur
some work on disk by Spark, and if this size is very great (e.g. 200,000
partitions) and your disk volumes are too small, you can run into errors like
the following:

```text
java.io.IOException: No space left on device
```

This happens because Spark will fill up the disk with temporary files. The best
way to avoid this issue with AQE is to set
`spark.sql.adaptive.coalescePartitions.initialPartitionNum` to a smaller
number, or increasing the temporary disk space available on the node.

Of course, the most optimum strategy is to avoid shuffling large amounts of
data altogether! To this end I recommend you consider the use of `groupByKey`
and `reduceGroups` on the DataFrame API.

Take the following snippet:

```scala
df.orderBy($"date")
  .groupBy($"store", $"sku", $"company")
  .agg(
    last($"skuDescription").as("skuDescription"),
    last($"storeDescription").as("storeDescription")
  )
  .as[BasicISAWithDescription]
```

Here I am taking a DataFrame, ordering it by the date, grouping it by some set
of keys and pulling out the latest description columns. A pretty standard
operation, but when you check the query plan under the hood of spark you can
see that this set of operations incurs at least 1 full hash-based shuffle of
the data on the `groupBy` keys.

You can achieve a similar result using a windowing function:

```scala
import org.apache.spark.sql.expressions.Window
val window = Window
  .partitionBy("store", "sku", "company")
  .orderBy(desc("date"))

df.withColumn("row", row_number().over(window))
  .filter($"row" === lit(1))
  .drop("date")
  .as[BasicISAWithDescription]
```

Again, analysing the query plan you will see this incurs a full shuffle of the
data.

When dealing with such large datasets we should attempt to avoid needless
network traffic. Which we can do by applying some local logic that gets us the
same results:

```scala
df.groupByKey { row =>
  (
    row.getAs[Int]("store"),
    row.getAs[Int]("sku"),
    row.getAs[Int]("company")
  )
}.reduceGroups { (r1, r2) =>
  if (r1.getAs[Date]("date").getTime > r2.getAs[Date]("date").getTime) r1
  else r2
}.map {
  case ((store, sku, company), v) =>
    BasicISAWithDescription(
      store,
      sku,
      company,
      v.getAs("storeDescription"),
      v.getAs("skuDescription")
    )
}
```

The above code avoids sending out the full dataset across the cluster and
instead does the following:

1. Groups locally on all nodes by the given keys
2. Reduces the dataset locally using the given function
3. Shuffles out the remaining data based on the given keys
4. Finally reduces the now grouped dataset

The final `map` step simply converts the grouped DataFrame to a DataSet as the
`as` method does.
