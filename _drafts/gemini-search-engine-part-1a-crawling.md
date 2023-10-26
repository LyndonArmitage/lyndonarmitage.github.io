---
layout: post
title: 'Gemini Search Engine Part 1a: Crawling'
tags:
- gemini
- search
- search engine
- crawling
- scraping
- programming
---

In this post I will go into the first part of building my
[Gemini](https://geminiprotocol.net/) Search Engine
[WhichFire](https://github.com/LyndonArmitage/WhichFire): Crawling/Spidering.

This is the first box in the high level design image I drew in my
[last post about building a Gemini Search 
Engine]({% post_url 2023-10-10-creating-a-gemini-search-engine %}).

<img
    title='The 3 high level components of our Gemini search engine'
    alt='Image showing the 3 high level components of our Gemini search engine,
    crawling is linked to data storage and retrieval, which is then linked to
    the front-end'
    src='{{ "assets/gemini-search/high-level-1.svg" | absolute_url }}'
    class='blog-image'
/>

I mentioned in that post that "the crawler does the majority of the work" when
it comes to search engines. It is responsible for crawling through the web of
connections in the search domain and sending all the relevant information to
the storage part of the system.

For the HTTP based world-wide-web, there is a plethora of tools already
available that can do crawling for you. Likewise, there's oodles of HTTP
clients and HTML parsing libraries to build your own. But, Gemini is a
different protocol, with different defaults. So how do I start designing and
building such a thing?

Luckily, the problem domain remains mostly the same: We'll be crawling what is
essentially a massive (cyclic) graph. The [Gemini protocol and common file
type](https://geminiprotocol.net/docs/specification.gmi)
are essentially implementation details at this high a level of design, although
we should keep them both handy as they can help us make some informed
decisions.

<img
    title='A crude example of what the WWW looks like as a graph'
    alt='A crude image reprsenting 2 websites, with their pages as nodes on a
    graph and the edges being the links between them.'
    src='{{ "assets/gemini-search/graph-example.svg" | absolute_url }}'
    class='blog-image'
/>

At the basic level, we can treat Gemini Space as a data source, it contains
within it all the nodes in the graph we want to discover and crawl through.
But, how do we get started on our crawling adventure? We need an existing list
of URIs to kick off our crawling.

<p class="message"> A note for readers unfamiliar with the term URI. It stands
for <a href='https://en.wikipedia.org/wiki/Uniform_Resource_Identifier'
target='_blank'>Uniform Resource Identifier</a> and is closely related to the
idea of a URL. I won't go into the nuances here, sufficed to say most of the
URIs dealt with will also be URLs, so we can use the term interchangeably most
of the time. </p>

Way back in the early days of the web, search engines would take existing
indexes, initially curated by humans, and from these they'd begin their
crawling to discover new pages and add them to their own indexes. Essentially,
all search engines are bootstrapped with some initial seed of information. And
this is how we will get our search engine going, we'll feed it an existing list
of domains and let it loose.

Admittedly, you could create a crawler that randomly tries to find valid URIs.
And in fact, randomly calling up IP addresses can find you computers on the
Internet, but it's a slow laborious practice, and when it comes to Gemini, we
are unlikely to find many servers in this manner. Generating potential URIs
from known domains is a more useful idea though, and this is often used by
hacking scripts to try and find administrator pages for websites, so it is
worth considering if we run into dead ends when looking for more pages (this is
very unlikely).

So we will be using a known list of URIs, specifically the list of Gemini
Capsules from the previously mentioned [Luna
indexer](https://portal.mozz.us/gemini/gemini.bortzmeyer.org/software/lupa/stats.gmi).

Gemini Capsule is the common name given to the equivalent of websites in Gemini
Space. Generally, a Capsule maps to a single domain name with one or more
pages.

<img
    title='A breakdown of the proposed crawling process'
    alt='The proposed crawling process. Consisting of multiple stages detailed
    below.'
    src='{{ "assets/gemini-search/crawling-1.svg" | absolute_url }}'
    class='blog-image'
/>

The proposed design for crawling is relatively simple:

1. A bootstrapping process will take data from a seed file and existing URIs
   from the data storage layer and push them to crawl queue.
2. The page crawler component will pop values of this queue and perform the
   actual crawl of the URI, pushing its results to a results queue.
   Additionally, it will push newly discovered URIs to the crawl queue.
3. A data writer component will take these results and write out to the data
   storage layer

Separating the crawling steps out in this way gives a few benefits:

Firstly, we can clearly define which components directly talk to Gemini Space.
This means that if we want to scale up or down the amount of active connections
to servers we can do so with ease.

Secondly, we decouple the separate processes with queues which makes it easier
to reason about what is happening in the system, recover and potentially
continuously run if desired. Queues also make it easier to parallelise,
provided there is no shared state.

Finally, we have clear integration points between different stages of crawling.
This enables us to iteratively improve separate parts of this pipeline without
having to refactor huge amount of code. This is essentially, one of the
benefits microservices have over larger traditional services. And, if we use
something like [Protocol Buffers](https://protobuf.dev/) to define the messages
sent between different stages, we can even rewrite slower performing code in
other programming languages.

Obviously, we currently don't have a data storage layer and consequently, we
have nowhere to store the results of these steps nor somewhere to get previous
results from. So our initial development and testing will focus on a small
subset of capsules to crawl.

We also need to define some way of limiting the crawling, at least for testing
purposes, so we don't end up crawling the whole of Gemini Space before we have
somewhere to store all that information. This can be done with limits on how
many links we dig through within a capsule/domain name, and hard limits on how
many capsules we will crawl overall. Annoyingly, this means our Crawl Queue
component will need to be a bit more complex than a simple queue data
structure.

Thankfully, we can define the important parts of the Crawl Queue ahead of time.
Below is some bare-bones Kotlin code to show the important parts of the API:

```kotlin
data class Capsule(
    val domain: String
)

data class CapsuleURI(
    val capsule: Capsule,
    val uri: URI
)

interface CrawlQueue {

    fun push(uri: CapsuleURI): Boolean
    
    fun pop(): CapsuleURI?
    
    fun size(): Long
    
    fun clear(): Unit

    fun seenURIs(capsule: Capsule, window: Duration): Long

    fun processedCount(duration: Duration) : Long

    fun processedCount(capsule: Capsule, duration: Duration): Long

    fun popForCapsule(capsule: Capsule): CapsuleURI?

    fun purgeCapsule(capsule: Capsule): Long
}
```

This should be recognizable as a kind of queue with the extra parts to it.
Namely, parts that allow for introspection and manipulation of the queue based
around a Gemini Capsule. It is also important to note the use of `Duration`
types for some of these methods. As mentioned before, the Crawl Queue will
likely be very long-lived, in fact it will be a constantly running service if
the search engine itself is constantly running. So, it makes sense that we'd
want to be able to define a window of time in which we want to be able to see
statistics from the queue for monitoring purposes from within the system
components so we can react appropriately.

Ideally, if set up at scale, the Crawl Queue would be reporting statistics to
some kind of aggregator. For example, we use
[DataDog](https://www.datadoghq.com/) at my current job, but Open Source
systems like
[Graphite](https://graphite.readthedocs.io/en/stable/overview.html) can also be
used to send numeric time-series data to. You could also build your own
monitoring systems, either building on Graphite as a data store and using tools
like [Grafana](https://grafana.com/) or using other data stores and
visualisation tools like [Kibana](https://www.elastic.co/kibana) or even
rolling your own.

With everything said, I've only scratched the surface of the first parts of the
Crawling subcomponent. I've not gone into the reasons for a separate writer nor
exactly what a crawling result looks like. These topics I will cover in the
next blog post in this series.
