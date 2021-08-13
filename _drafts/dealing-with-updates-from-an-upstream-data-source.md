---
layout: post
title: Dealing with Updates from an Upstream Data Source
tags:
- spark
- data
- data lake
- big data
---

Recently at we have been running into an interesting problem at work: one of
our data sources is a transactional database (a mainframe) that has data
updated. The data is updated relatively regularly to begin with then it may be
sparsely updated over a longer windows of time, up to a month or so. We need to
get this into our Spark based Data Lake but, unfortunately, we don't have
access to a Change Data Capture (CDC) process.

For example our source data could be simplified as the following table ranging
over 3 dates (as of the final date):

| added_date  | id   | status | other_data |
| ----------- | ---- | ------ | ---------- |
| 2021-01-01  | 1234 | CLOSED | fixed      |
| 2021-01-01  | 1235 | CLOSED | fixed      |
| 2021-01-02  | 1236 | CLOSED | fixed      |
| 2021-01-03  | 1237 | OPEN   | changing   |
| 2021-02-03  | 1238 | OPEN   | changing   |

Our initial solution to this problem was a very simple snapshot upload to the
Data Lake. Every day we'd query the source system and upload the snapshot. We'd
keep the previous snapshots allowing us to see the updates. This meant our data
storage size grew heavily with the data. The tables where the data resides grow
roughly linearly with time as old data is almost never purged from them.

This could result in our example snapshot data looking similar to:

| ingest_date | added_date  | id   | status | other_data |
| ----------- | ----------- | ---- | ------ | ---------- |
| 2021-01-01  | 2021-01-01  | 1234 | OPEN   | changing   |
| 2021-01-01  | 2021-01-01  | 1235 | CLOSED | changing   |
| 2021-01-02  | 2021-01-01  | 1234 | CLOSED | fixed      |
| 2021-01-02  | 2021-01-01  | 1235 | CLOSED | fixed      |
| 2021-01-02  | 2021-01-02  | 1236 | CLOSED | changing   |
| 2021-01-03  | 2021-01-01  | 1234 | CLOSED | fixed      |
| 2021-01-03  | 2021-01-01  | 1235 | CLOSED | fixed      |
| 2021-01-03  | 2021-01-02  | 1236 | CLOSED | fixed      |
| 2021-01-03  | 2021-01-03  | 1237 | OPEN   | changing   |
| 2021-02-03  | 2021-01-03  | 1238 | OPEN   | changing   |

You can see the duplication over time for each ID, and the state an ID was in
at the time of a snapshot (denoted by the ingest_date).

Several times we opted to resize the clusters processing this data as a
stop-gap measure. Finally, it became clear that we needed a better solution.
For other tables, that were only appended to, we could easily incrementally
build a table in our Data Lake. For these tables we needed a slightly different
strategy.

Tools like Snowflake, Firebolt, and Delta Lake all handle doing such upserts.
For example Delta Lake let's you merge new data using the [SQL command
Merge](https://docs.databricks.com/delta/delta-update.html#upsert-into-a-table-using-merge).
For our situation we needed to be able to do something similar ahead of these
technologies.

To recap on the situation:

* We have a set of tables containing data in an external, transactional system
  that are updated for a brief period of time before remaining essentially
  untouched.
* We have no access to a Change Data Capture (CDC) process
* The source data is not often purged and grows linearly with time
* We want to be up-to-date on a daily basis
* Our current approach is to snapshot data every day and export it to the Data
  Lake.

After some discussion we came upon a potential solution. We split the data. The
larger, non-changing data, we will call "frozen". The smaller part that can
change we will call "in flux".

To simplify I will assume we are working on only a single table but the
situation can be applied to multiples:

1. Every day we will grab a new copy of the "in flux" data. This represents a
   window of time over our table.
2. From the previous "in flux" data we write out any values that have fallen
   out of the window to the "frozen" data.
3. We create a table that is a merge of the "frozen" and "in flux" data for use
   by other downstream processes.

<img title='The prcess as a simple diagram' alt='The process as a simple diagram' src='{{ "assets/in-flux/simple-process.svg" | absolute_url }}' class='blog-image' />

This approach means we are only copying a smaller, fixed sized, window of data
from our source system daily. This data may vary in size but it will not be
ever increasing.

If we visualise the data on a time line it looks as follows:

<img title='Diagram of the data in a timeline' alt='Digram of the data in a timeline' src='{{ "assets/in-flux/time-grid.svg" | absolute_url }}' class='blog-image' />

This approach also means we only perform inserts on the "frozen" data, not
updates. We also do not create constant snapshots of the source system.

One caveat of this approach is that if the source data changes beyond our "in
flux" window we will not capture this change. This unlikely situation can be
worked around by simply replacing the "frozen" data with a snapshot of the
source system with the "in flux" window omitted from it. In fact, if we
automatically did such every few weeks we'd have an "eventually consistent"
copy of the source data.

This solution also works well with the existing data in the Data Lake. We
already have full snapshots that can be used to generate the "frozen" table.
The differences between the existing snapshot table and new table is size and
the omission of an ingest date column.

The solution does involve a little more juggling of data: We load less data
externally but we merge our window daily into the frozen data. Thankfully, with
the data partitioned by date this mostly amounts to simple copy actions.
Additionally, downstream uses of this data source do not have to contend with
the whole snapshot history of the data.

If historic snapshots are still desired we can continue to take them but this
solution divorces them from the rest of the processing pipeline. We could also
adapt this solution to store multiple values per ID during the window of change
only, for a more hybrid solution.
