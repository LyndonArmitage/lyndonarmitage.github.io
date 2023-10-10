---
layout: post
title: Creating a Gemini Search Engine
tags:
- gemini
- search
- search engine
- scraping
- crawling
- data
- programming
date: 2023-10-10 12:38 +0100
---
This is the first post in a series about creating a search engine for the
[Gemini internet technology](https://geminiprotocol.net/). In it, we will
briefly discuss what Gemini is and the basics of creating a Search Engine.

## WTF is Gemini?

Gemini is a protocol and accompanying MIME type that are designed to be a slim
down equivalent to HTTP and HTML. In their own words:

> Gemini is a new internet technology supporting an electronic library of
> interconnected text documents. That's not a new idea, but it's not old
> fashioned either. It's timeless, and deserves tools which treat it as a first
> class concept, not a vestigial corner case. Gemini isn't about innovation or
> disruption, it's about providing some respite for those who feel the internet
> has been disrupted enough already. We're not out to change the world or
> destroy other technologies. We are out to build a lightweight online space
> where documents are just documents, in the interests of every reader's
> privacy, attention and bandwidth.

Essentially, it is a protocol built on-top of TCP (like HTTP) and SSL (like
HTTPS) for serving documents over the internet. Along, with the protocol a
lightweight text format is specified that is similar to the likes of Markdown.

Gemini is similar to the [Gopher
Protocol](https://en.wikipedia.org/wiki/Gopher_(protocol)) in its simplicity,
but it's been designed alongside the modern web, as opposed to during the web's
infancy.

Currently, according to an
[existing indexer of Gemini](https://portal.mozz.us/gemini/gemini.bortzmeyer.org/software/lupa/stats.gmi),
there are almost 600,000 unique URIs on Gemini. This is a lot less than the
standard, HTTP based, world-wide-web. Likewise, most of the pages hosted by
Gemini are far less than even a megabyte inside, again unlike the modern web.

## Why Build a Search Engine for Gemini?

First and foremost, it's an interesting exercise. It involves learning a new
protocol and file format, and producing tools to work with that. Additionally,
it allows me to both hone some of my existing skills and knowledge, as well as
share it in a constructive way. Finally, Gemini is a much smaller and simpler
domain to the standard world-wide-web, so it will be (in theory) easier to deal
with.

There already exists a very good crawler of Gemini space in the program
[Lupa](https://portal.mozz.us/gemini/gemini.bortzmeyer.org/software/lupa/),
(where I got the previous stats from). Lupa is written in Python by Stéphane
Bortzmeyer, with its source code available at
[https://framagit.org/bortzmeyer/lupa](https://framagit.org/bortzmeyer/lupa).
It does not function as a full search engine however, as it doesn't index the
contents of URIs, it rather scrapes them for links and stores the metadata
about the pages it visits.

What we want to do is not only create an index of URIs in Gemini space, but
also allow users to search through it in a similar way to how you'd use a web
search like [DuckDuckGo](https://duckduckgo.com/),
[Google](https://www.google.com/), or [Bing](https://www.bing.com/). That is,
you type in a search query, and get a response containing (hopefully) relevant
pages as a response. That is in essence what a search engine is; a tool for
finding information from a data source.

## Anatomy of a Basic Search Engine

<img 
    title='Google is the most widely used search engine in the world.'
    alt='The Google logo'
    src='{{ "assets/gemini-search/Google_2015_logo.svg" | absolute_url }}'
    class='blog-image'
/>

At its core a basic search engine is made up of 3 components:

1. A crawler, sometimes called a spider
2. A database
3. A front-end for users to perform searches with

The crawler does a majority of the work, it's named such as it crawls through
all (ideally) the resources in the domain you want to search, and stores
relevant information in the database.

The database stores all information about the domain being searched. It might
also rank the information in some way based on the information given. When it
comes to search engines, the database often also models connections between
different entries within it in a graph structure.

The front-end of a very basic search engine is essentially just a portal into
the database that a user can use to query it. As search engines have become
more sophisticated, their front-ends have increased in complexity and
user-friendliness, allowing for them to understand more complex queries.

The above is the anatomy of a basic search engine. Large production-scale
search engine like DuckDuckGo and Google will be many times more complicated
when it comes to how they are constructed, but the basic 3 components remain
largely the same.

So, in order to create our basic Gemini search engine we will split development
along these 3 key lines; crawling, data storage and retrieval, and front-end.

<img 
    title='The 3 high level components of our Gemini search engine'
    alt='Image showing the 3 high level components of our Gemini search engine,
    crawling is linked to data storage and retrieval, which is then linked to
    the front-end'
    src='{{ "assets/gemini-search/high-level-1.svg" | absolute_url }}'
    class='blog-image'
/>

In the coming blog posts I'll be focussing in on each of these components and
the resulting subcomponents and design decisions that arise when dealing with
each of these parts. You can follow the progress on this blog and also follow
the [project on GitHub](https://github.com/LyndonArmitage/WhichFire).
