---
layout: post
title: Extracting Published Dates from web pages
---

One objectively useful piece of information often present on news and blog post
articles online is the date of publication.  
It can be used to determine how fresh and relevant an article is and when used
in conjunction with other processing allow you get a feel for the subject of 
the article, be it a company, person or event.

At [Synoptica](https://www.synoptica.com/) I worked on improving the accuracy 
of getting such a published date (and sometimes time). 

Interestingly this is a harder task than you might naively believe it to be.

## Challenges

Surely you can just grab the first date you see on a web page and be done 
with it right? Nope.  
Often a web page will have many dates on it, some from other articles, 
adverts or even today's date. 

So grabbing the first one you see is not good enough, but even if it was we'd 
still have the problem of what we consider a date.  
Americans like to use the (confusing) date format of `mm/dd/yyyy` compared to 
`dd/mm/yyyy`, but often websites also use a textual representation of the date 
like `Monday 21st January 2008` or `August 3, 2009`, with many variations of 
order and punctuation.

Some websites might not even include the date of an article on it's page in 
text but instead encode it in the URL like: 
`https://example.com/2012/1/1/happy-new-year` or in elements within the page.

But there must be "a standard" for presenting dates on articles online right?
Otherwise how do the likes of Google, Bing, Twitter, Facebook and others show
nice summaries of web links to news articles?

Well there are **standards**, [plural](https://xkcd.com/927/):

* [The Open Graph protocol](http://ogp.me/) is a standard that allows for 
  adding rich metadata to a web page that the likes of Facebook consume, this 
  includes `article:published_time` which can be used for determining a 
  published date
* [schema.org](https://schema.org/) promotes another (large) standard for 
  adding metadata to web pages including quite a few different variations of 
  dates that can be used as published dates. It can also be encoded into a
  [json-ld](https://json-ld.org/) file included with a web page
* Many content management systems (CMSs) and publishers also have their own 
  ways of encoding a published date in a pages metadata or tags. 
  E.g. The Wall Street Journal uses the `<meta>` tag named `article.published` 
  and Metro uses one named `sailthru.date`

## Solving it

So that's 3 places we can get a published date (and maybe time) from:

* Text within the web page
* The web page's URL
* The metadata on a web page

All these can be in various formats so we'd need to be able to parse them to 
dates (and maybe times for some) reliably.

A website might have many dates on it so we'd also want to be able to determine
which one is the most likely published date as well.

We'd want to cover as many websites as possible and make it easy to add more 
"rules" to such a system.

A decent solution to this (and the one I took) would be to:

1. Encode all the common patterns into their own rules.  
   For instance create a process to decode a URL and extract anything that 
   looks like a date in it like `https://example.com/2008-02-21/article` or 
   `https://example.com/2012/12/15/article`, other processes for the common 
   metadata patterns, and more still for searching for date patterns in a pages 
   content.
2. With the dates output by the above processes; evaluate them and determine a 
   most likely published date.

The first step is simple enough and can be structured in such a way that it is 
easy to add more rules to as you discover them and modify existing ones.  
I did this using classical Java and Object Orientated patterns; defined a 
common interface for processing a web page and it's URL, then implemented types
based on this interface, taking advantage of inheritance to divide similar 
rules into simple type hierarchies to reuse common behaviours.

<img alt='Simple class diagram' src='{{ "assets/dates/simple-class-diagram.svg" | absolute_url }}' class='blog-image'>

The second step requires some intelligence and reasoning. One simple algorithm 
might be to use the date that appears the most for a given page, ordering those
with similar counts by recency. A more intelligent one might be to weight the 
output of the various rules, since some may be more likely to be right than 
others, e.g. the date in a URL is likely right.

With these steps in place you could now easily evaluate a list of URLs and 
determine when they were published, outputting such information in a standard 
way ([ISO-8061](https://en.wikipedia.org/wiki/ISO_8601) is nice) e.g.

| URL | Published Date (with time) |
| --- | -------------------------- |
| https://edition.cnn.com/2018/09/02/health/cuba-china-state-department-microwaves-sonic-attacks/index.html | 2018-09-02T20:13:34Z |
| https://www.bbc.co.uk/news/business-45394226 | 2018-09-03T14:27:52+01:00 |
| https://www.dawn.com/news/1430365 | 2018-09-02T00:55:02Z |
| https://dolphin-emu.org/blog/2018/09/01/dolphin-progress-report-august-2018 | 2018-09-01T00:00:00Z |
| https://www.wsj.com/articles/new-speed-bump-planned-for-u-s-stock-market-1535713321 | 2018-08-31T11:02:00Z |
| https://www.bbc.co.uk/news/uk-england-surrey-44291716 | 2018-05-29T15:49:31+01:00 |

## Conclusion

I built such a library over a short period of time in Java that covered many 
different cases over many different websites, 51 in my original hand curated 
tests.   
It could handle at least 19 different date formats that I had seen, some 
including time and offset information.  
It was also easily extensible, with tooling allowing me to explore pages for 
potential new patterns and improvements to existing ones.

At [Synoptica](https://www.synoptica.com/) the extracted date is used to 
determine relevant articles to a company and used in scoring companies in 
various categories like funding, corporate social responsibility, security, 
recruitment etc.  
The more accurate a date (and maybe even time) the more accurate results are.

As a result of this being work related the code is property of Synoptica but 
the process itself should be relatively easy to reproduce, in fact there 
already exists at least one project that does something similar to this in 
Python for those requiring a ready-made solution:
[Webhose article-date-extractor](https://github.com/Webhose/article-date-extractor).  
I am unsure on the licensing of this project however, and do not know if it is 
actively maintained. I encountered it when I had already developed most of the 
rules in my own project and was relived to see they had a similar approach to 
my own (albeit in differently structured Python code).

Overall this was an interesting self contained problem that was well defined 
and relatively easy to solve. I'd be tempted to attempt a solution again in my 
own time and evaluate potential alternatives and new possible patterns.

One interesting possibility would be to implement this using machine learning 
to assist in step 2. That is, if given enough context around each extracted 
date you could potentially train a model that would decide which is the most 
likely date for a given web page. A similar approach is taken to eliminate
adverts and boilerplate parts of web pages by the project 
[Dragnet](https://github.com/dragnet-org/dragnet).

