---
layout: post
title: Data Engineering the Right to Erasure
tags:
- data
- programming
- ingest
- gdpr
- right to erasure
- rte
- privacy
date: 2024-11-18 12:39 +0000
---
GDPR and specifically, the [Right to
Erasure](https://gdpr-info.eu/art-17-gdpr/) (aka 'right to be forgotten') are
tough nuts to crack in the world of Data. Given our predilection to data
hoarding the requirements to be able to erase user information in a timely
manner can prove difficult when you have a huge data estate.

Right to Erasure often runs antithetical to how we tend to think of data in the
Data Engineering world. Storage is relatively cheap, thanks to block
stores like Amazon S3, so instinctively our ingests tend to follow a pipeline
pattern of landing data, potentially transforming it, then passing it off to
our consumers. It's essentially verboten to go in and modify data that has
landed, beyond compacting it, moving it, or compressing it, we tend to think of
it as static, but that's a bad assumption in the age of GDPR.

Having designed and worked on retrofitting a customer friendly Right to Erasure
system onto an existing data estate, I can say that it's not a simple feature.
Ideally, you take privacy matters and now erasure concerns into account from
the offset. You bake in these features as you build your systems. However, there
is a high chance you aren't building from scratch, there are existing
processes, and there is always a need to balance up-front work with business
goals and priorities.

To this end, here are a few hints to help you along:

## Only Store Sensitive Data You Actually Need

This is an easy one, but could be hard depending on your attitude towards data.
Whenever data comes into your systems that is sensitive or could be used to
glean sensitive information on a customer, think for a moment if it is needed.

Extraneous information like IP addresses, or certain cookie contents might seem
like it __could__ be useful, but storing such information when there is no plan
to use it increases risks with little chance of reward. If you don't have the
data, there's nothing to erase.

## Organisation Wide Buy-in

Just like "no man is an island entire of himself", no Data team is separate
from the wider business it inhabits. When dealing with customer erasure
requests you don't just need Data systems, you need buy-in and support from the
wider organisation you work in. You will need to at minimum orchestrate with
the teams who accept erasure requests, and those responsible for the upstream
and downstream systems that you pull and push data to. This is vital to ensure
that details that were supposed to be erased don't sneak back into your Data
systems from elsewhere.

## Dude, where's my data?

In order to erase or anonymise data you need to know where it is. That may seem
obvious but the implications need to be understood. When you manage a large
enough data lake, you need to have a good solution to answer the questions:

1. Where is the sensitive information in the data lake? What tables/prefixes?
2. What are the sensitive information fields in each object we store?
3. Where is the sensitive information for a specific customer across our whole
   data estate?

The first 2 can be covered relatively well with good data lineage and
cataloging habits. Ideally, you'll have some kind of index describing all the
data in your estate, making it easy to filter down to a subset of files and
columns within them that contain sensitive data.

The third one can be a bit more tricky, especially when you have a big data
estate. It involves keeping track of what you deem identifiers within your
estate in some large index. You should do this at ingest time whenever
possible, but you will likely need to bootstrap such a process by scanning all
your datasets identified by questions 1 and 2. The best approach when you are
in the dark on this is to get the on-ingest index building working and then
perform a large-scale scan of the previously not indexed estate. Unfortunately,
if you actively need to comply with erasure requests you have already been,
given you will likely need to do these steps in an out of order fashion.

The reason I suggest using indexes here is simple. On a smaller scale you may
be able to run large jobs (be they Apache Spark or something else) across your
data estate in a relatively short time or cost, but as your data scales this
becomes a very expensive process in terms of both time and cost.

One big thing to watch out for with indexing your data is heavily nested data
and data whose schema can vary wildly from record to record.

## Enrich the Requests you are given

Customer requests for erasure may not contains all the identifiers for that
customer. They can be sparse and only include an email or other single
identifier. You will need to enrich any requests using the knowledge stored in
your sensitive information index.

This means, when given a customer email address, you find all the other
identifiers that can be associated with that customer. In an ideal world, this
is a relatively simple affair as you'll have them all aligned in some dataset
somewhere.

## Stage your Erasures

You don't test in prod, so don't erase in prod. At the very least, don't commit
your erasures until you are sure you haven't erased more than you needed to.

A positive of the ubiquitous block store is that objects are often versioned.
This gives you some assurances when updating your data with erasures but it is
also another potential pitfall. You need to remember to delete the previous
versions containing the erased information.

## Conclusion

These are just a few important details you need to take into account when
dealing with Right to Erasure. If there is interest I can go into excruciating
detail related to building and deploying such a system.
