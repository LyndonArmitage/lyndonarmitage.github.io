---
layout: post
title: Basic Tips for Improving Performance on Spark Jobs
---

As part of my day job I tend to have to look at and optimize Spark jobs written
by others that can end up joining up a lot of data sources that can vary in
size wildly.  
Often these jobs may have started their lives as Notebooks that are written as
needed by people with various levels of experience with Apache Spark.

Below is a (non-exhaustive) list of some common patterns that I employ to
improve performance on Spark jobs in general:

## Filter Data as Early as Possible

One thing that always has a major effect on performance is the sheer amount of
data being processed. And one way of handling this is to ensure that input data
is filtered as early as possible.

So whenever I see a filter within a job I look to see if it is possible to pull
it back closer to when we initially read data.

This works well for historic data where we only want a limited subset of data
for some period of time.

It also works well for source data that contains entries we want to filter out,
for example, if you want to create a report based on transactions where the
customer used a loyalty card you are better off filtering the transactions first
to eliminate transactions without loyalty cards before joining such data with
anything else

## Join Small Datasets First

In jobs that contain a lot of joins between many related datasets it can be
beneficial to perform the joins between smaller tables first before joining
larger ones, especially for outer joins.

## Broadcast Small Datasets

One cool feature in Spark is the idea of Broadcast Joins.  
These are joins where one side of the join is transmitted to all executors
involved in it's entirety.

This means that no additional shuffling needs to take place.

Luckily Spark is optimized to do this automatically to some extent. By default
any dataset that is below 10M in size is eligible to be broadcasted across the
cluster but you can specifically request something to be broadcasted using the
`broadcast` hint method.

For more information on Broadcast Joins you can read
[this article](https://jaceklaskowski.gitbooks.io/mastering-spark-sql/spark-sql-joins-broadcast.html)
on the internals of Spark.

## Broadcast Poorly Distributed/Fragmented look-up tables

Another time Broadcast Joins can be useful but on slightly larger datasets is
when you are joining with a widely distributed look-up table.  
By this I mean a table that when joined against would result in a lot of
shuffling anyway.  

For example; if you had a lookup table pairing an anonymised loyalty card
number to some anonymised customer ID, or group, the anonymised number will
likely be highly random in how it structured and partitioned across the
cluster.  
This would mean that any joins against such a number on a reasonably sized
dataset could end up causing a lot of shuffles of this data to each task.
Something we can pre-empt with use of a Broadcast Join.

## Take advantage of Predicate/Filter Pushdown

[Predicate Pushdown](https://jaceklaskowski.gitbooks.io/mastering-spark-sql/spark-sql-Optimizer-PushDownPredicate.html)
is a complicated sounding name for a simple concept in Spark that can really
improve performance of queries.

It is basically the optimization of performing filter operations at the lowest
level possible, the data source.  
For database based data sources that would
involve getting the database to perform the filters, allowing them to make use
of any indexes.  
For S3, Orc or other data sources stored on a file system it can make use of
folder based partitions.

A common pattern I have used is to partition data when writing out to Parquet
on date or some other fairly evenly distributed field that is used often in
queries.  
Of course this relies on you having control over your data sources and can mean
having additional jobs to do this partitioning.  
I work using a Data Lake to store our various datasets from many systems and
make use of scheduled Spark jobs on Databricks and Airflow to perform scheduled
imports into it that perform this partitioning.

## Save intermediate tables for reuse

Some calculations naturally take a long time to complete and only need to be
done occasionally, for instance creating lookup tables from large data sets or
cross joining data.  
In these circumstances you may want to save the results to an intermediate
table or file so they can be reused instead of recalculated in the event of a
cluster malfunction or even between job runs.

A side effect of writing out the results of a calculation is that you can also
write it so that subsequent uses of the data can take advantage of predicate
pushdown. It also allows you to keep your cluster sizes smaller in the event
when only part of your job requires heavy calculation.

## An Example

It's probably hard to visualize using these tips without an example.  
So let's explored one:

In this example we have the following tables:

* An item table; containing the ID of an item, it's name, and price.  
  This could contain a lot more item specific fields.
* A sales table; containing the sales of items within a basket
* A basket table; containing some data on individual baskets
* A loyalty card look-up table; pairing loyalty cards to some ID in another
  system

In this example we will want to find all sales that contain a certain item by
customers with a loyalty card where the total basket value is over some
threshold amount, in the last week.  
In this instance let's say we want to know all the sales of protein shakes in
baskets over the value of £100.

An initial, sub-optimal job might look like the following:

```scala
val items = spark.read.parquet("/example/items")
val sales = spark.read.parquet("/example/sales")
val baskets = spark.read.parquet("/example/baskets")
val loyalty = spark.read.parquet("/example/loyalty")

val joined = sales
  .join(items, items("id") === sales("item_id"))
  .join(baskets, "basket_id")
  .join(loyalty, "loyalty_card")

val result = joined
  .filter(col("loyalty_card").isNotNull)
  .filter(col("total") >== lit(100))
  .filter(col("item_id") === lit(123))
  .filter(col("timestamp") >== date_sub(current_timestamp(), 7))

result.show()
```

On a small enough set of data this would be fine but applying the processes
I mention above we can hopefully improve the performance on larger datasets:

```scala
val dateLimit = date_sub(current_timestamp(), 7)
val items = spark
  .read.parquet("/example/items")
  .filter(col("id") === lit(123))
val sales = spark
  .read.parquet("/example/sales")
  .filter(col("sale_timestamp") >== dateLimit)
val baskets = spark
  .read.parquet("/example/baskets")
  .filter(col("timestamp") >== dateLimit)
  .filter(col("loyalty_card").isNotNull)
  .filter(col("total") >== 100)
val loyalty = spark.read.parquet("/example/loyalty")

val result = sales
  .join(broadcast(items), col("id") === col("item_id"))
  .join(baskets, "basket_id")
  .join(broadcast(loyalty), "loyalty_card")

result.show()
```

Note that the differences are subtle.  
