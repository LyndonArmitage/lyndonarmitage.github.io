---
layout: post
title: Trimming the Fat
tags:
- blog
- google
- bloat
- website
date: 2021-03-15 12:00 +0000
---
After spotting a link on Fosstodon to the
[Web Bloat Score Calculator](https://www.webbloatscore.com/) and investigating
my scores on
[Google's PageSpeed Insights](https://developers.google.com/speed/pagespeed)
I decided to reduce some of the "bloat" on my site.

Namely this was:

* The elimination of Google Analytics
* Reducing the quality of my single profile picture
* Removing the Web Fonts I was using

### Removing Google Analytics

I had forgotten I had Google Analytics until a few weeks ago so they weren't
being used yet data was being collected. This meant that I was gaining nothing
from the analytics whilst Google was adding it to their ever growing databases.
And as someone who values privacy online that's not something I really want to
expose my visitors to if I can help it.

Thankfully the way Google Analytics is added is pretty simple, it's a script
tag in your HTML. And the way I added it was with an include in my Jekyll
templates so I had to remove one line of code to remove it.

If I need analytics I will be investigating
[plausible.io](https://plausible.io/) as they have their own open source
alternative that can be self hosted, putting all data in my hands alone.

### Reducing Image Quality

I currently have a single image of myself on this blog that I load in the
side-bar of every page.

Awkwardly this image is actually a high resolution photo scaled based on your
window size. I did this mostly out of laziness as generally you want to use
pre-scaled versions of an image for different view-port sizes so as to not
waste your visitors bandwidth.

My rather lazy solution to reducing this 300+KiB image to something a little
more reasonable was to run a tool called `jpgoptim` on it to subtly reduce its
quality. This resulted in something you could only notice if you looked at the
original next to the reduced quality. Specifically I reduced it to be around
100KiB big, 3 times smaller:

```bash
jpegoptim --size=100k profile.jpg
```

If you use `png` images on your site I can recommend the tool `pngquant` which
basically does the same thing for `png` images except the quality reduction is
even less noticeable.

### Removing Web Fonts

I was using the web font [PT Sans](https://fonts.google.com/specimen/PT+Sans)
that was pre-configured in the Jekyll CSS I based my site off of.

This font is very nice! But it adds unnecessary requests (and rendering changes
when it's loaded) to my site compared to using a font like Helvetica that is on
basically all systems by default. The slight differences aren't really worth
the extra trouble of loading in the WOFF file and CSS defining it.

## End Result

The end result of these endeavours was that my "bloat score" went down and my
PageSpeed score went up, additionally my site is no longer making any third
party requests.

Ironically this is all a bit of
[Yak Shaving](https://en.wiktionary.org/wiki/yak_shaving) as the main thing
slowing my site down is being hosted on GitHub Pages.
I am tempted to migrate away to self hosting as it gives me more control over
the site in general but that's something to explore a little later.

