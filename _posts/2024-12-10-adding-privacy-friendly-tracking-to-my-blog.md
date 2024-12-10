---
layout: post
title: Adding Privacy Friendly tracking to my Blog
tags:
- privacy
- blog
- tracking
- goatcounter
- goaccess
- analytics
date: 2024-12-10 11:04 +0000
---
I've recently caved into the idea of adding some tracking onto my blog, but
rather than cave completely to the likes of Google Analytics, I've opted to
investigate some minimal, privacy friendly tracking solutions.

In the past I've been happy blogging to the void and not knowing how popular my
posts are or where they're being linked from, but recently, with my [Advent of
Code posts]({% post_url 2024-12-06-advent-of-code-2024-summary-days-1-to-6 %}),
I've been interested in how many people if any have actually seen them.
Additionally, the basic analytics you get from platforms like X and LinkedIn
aren't always sufficient.

So my first port of call was to figure out what was out there. Recently, we've
been evaluating ChatGPT Enterprise at my work, so I thought I'd challenge it to
find me a privacy respecting analytics solution. At first it mentioned
[Plausible](https://plausible.io/) and [Fathom](https://usefathom.com/) as
options, but when I drilled it for open-source, self hosted options it listed
several more:

- [Matomo](https://matomo.org/)
- [GoAccess](https://goaccess.io/)
- [Umami](https://umami.is/)
- [Ackee](https://ackee.electerious.com/)

Of the second batch, GoAccess and Umami looked like the simplest to get started
with, along with Plausible from the first two suggestions, that gave me 3
options to investigate.

ChatGPT did provide some limited information on each option, but I still don't
fully trust its results and in general wanted to do further research on each
option. So I fired up the web browser and opened up each options home page, as
well as did a quick search for each.

## Resource Usage

One of the reasons I had been reluctant to install analytics, other than
apathy, was that any service would need to consume some resources, and the 3
options are no different. Each needs some amount of memory and CPU time, but
they also need somewhere to store their data. Umami and Plausible both need
some kind of SQL database, whereas GoAccess stores its data in memory and
persists locally to disk.

Recommended resources seemed to be around 2GB of memory for [Plausible
CE](https://github.com/plausible/community-edition/).
[Umami](https://umami.is/docs/install) didn't list exact system requirements,
but it does need both a NodeJS server and MySQL/PostgreSQL server running.
[GoAccess](https://goaccess.io/faq) seemed to be the most lightweight in terms
of resources, according to it's documentation its memory footprint is dependent
on the log size it parses.

I use [DigitalOcean](https://m.do.co/c/f024e981a0f8) for my hosting.
Specifically I use their [App
Platform](https://docs.digitalocean.com/products/app-platform/) for my blog,
and one of their droplets for hosting some subdomains. This complicates things.
My deployment is done automatically upon pushing to my Blog repository which is
a very nice feature, the SSL is all automated, and the cost is non-existent
from the blog side of things (the App is free in DigitalOcean).

With relative ease, I can deploy whatever solution I come up with to a
subdomain on a droplet, in fact I already do similar for some other projects.
This will inevitably incur some kind resource cost but I'd prefer to keep this
to a minimum.

## GoAccess

So, of the 3 I highlighted, GoAccess has the least amount of dependencies and
resource usage.

In my exploration of articles related to GoAccess, I found [this blog post by
Ben Hoyt](https://benhoyt.com/writings/replacing-google-analytics/) from 2019,
about replacing his Google Analytics with GoAccess. I also found this [thread
from Hacker News](https://news.ycombinator.com/item?id=21890027) linking to [a
blog post by Deni
Bačić](https://b4d.sablun.org/blog/2019-12-23-own-your-website-stats/).

Ben Hoyt's post was quite extensive at explaining the process he took. He also
had a similar situation with how his blog was hosted compared to mine, except
he uses [GitHub Pages](https://pages.github.com/), something I migrated away
from. He opted to host a special tracking pixel on Amazon S3 via CloudFront.
This would produce logs he'd process with GoAccess.

Hoyt's approach had the benefit that some analytics would still be collected if
you block JavaScript, as the tracking pixel (sometimes called a [web
beacon](https://en.wikipedia.org/wiki/Web_beacon)) will still be loaded,
barring any blocking software.

Hoyt also mentioned at the top of his article that he later replaced GoAccess
with something called [GoatCounter](https://www.goatcounter.com/).

If I wanted to apply a similar process to Ben Hoyt, I could host a tracking
pixel at a subdomain and process the logs it produces. Specifically, I could do
this in a lightweight way with an existing DigitalOcean droplet and Nginx
instance. This would be a little simpler than Hoyt's approach as I would not
need to convert logs and could run GoAccess on the same location.

## GoatCounter

Before I jumped down the rabbit hole of implementing a GoAccess solution, I
paused to look into GoatCounter. There was obviously a reason why Ben Hoyt
opted to migrate to GoatCounter within 2 years of using GoAccess. Hoyt actually
wrote another [article for LWN.net](https://lwn.net/Articles/822568/) about
GoatCounter and Plausible. In it he highlights the benefits of these two
open-source analytics solutions, one such benefit of GoatCounter is that it is
free for personal use. In theory this means I would not need to host anything
at all

Of course, one issue using any third-party analytics, even non-invasive ones,
is that they are easily blocked by ad-blockers and hosts lists.
[GoatCounter](https://github.com/arp242/goatcounter/issues/349) is no
different. However, as that GitHub issue highlights, you can host the
GoatCounter `count.js` script elsewhere, and proxy your requests through your
own domain to GoatCounter if desired, or self host it entirely.

After looking into GoatCounter, it seems even more lightweight than GoAccess.
This means that self-hosting it won't break the bank or take up inordinate
resources.

## Conclusion

With all that investigation done, I opted to use
[GoatCounter](https://www.goatcounter.com/). For now I am not self-hosting it,
instead I will be using the simple support provided while I evaluate it. This
does mean it can be blocked by ad-blocking scripts, so I may get only limited
analytical information from it, but it can still be a useful tool.

I will likely revisit the idea of analytics in the new year, perhaps I will
migrate to GoAccess, self-host GoatCounter, or even implement something
incredibly basic myself, based on a simple tracking pixel and/or custom script.
Until then I'd love to know what privacy conscious solutions others have used
for tracking their personal blogs.
