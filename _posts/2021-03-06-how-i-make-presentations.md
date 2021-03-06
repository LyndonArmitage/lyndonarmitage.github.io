---
layout: post
title: How I make presentations
tags:
- revealjs
- presentation
- html
- open-source
- free
date: 2021-03-06 11:34 +0000
---
I dislike PowerPoint. There I said it. While it's an okay tool for many I often
find it cumbersome. Not to mention that it is a Microsoft product. I've tried
various alternatives to it but they all seem to be trying to emulate the
experience: Google Slides is okay but it's stuck in the web browser and is owned
by Google, another massive corporation with it's own set of problems.  
LibreOffice and OpenOffice both have their own along with Calligra but they're
even more cumbersome than PowerPoint to use, MacOS has Keynote but that again
is a massive corporation run tool. What I have settled on using for a while now
is [reveal.js](https://revealjs.com).

Reveal.js is a free open-source HTML based presentation framework that works in
any modern web browser. It has support for writing in Markdown (what these
articles are written in) along with writing in pure HTML.

So the catch with reveal.js is that you are writing your presentation in HTML
or another markup language rather than editing it in a WYSISWYG editor, that
actually suits me. Since I have been writing HTML for years I don't find it
annoying to write in it, and if I don't want to worry deeply about how a slide
will look I can even resort to writing it in markdown.

However, if you really want a nicer more what-you-see-is-what-you-get experience
then the same original author of reveal.js runs a subscription service called
[slides.com](https://slides.com) that helps you create reveal.js presentations.
I am not endorsing this however as I have never used it.

With writing presentations as code I get the benefit of being able to use git
to version control the presentation. With them being HTML I can present them on
basically any device! And additionally if needed I can adjust or augment my
presentations with anything the web has to offer; I can embed a YouTube video or
use an animated GIF as a background, take advantage of vector image formats like
SVG so my images scale at any resolution, make use of web-fonts and I can theme
them with CSS.

There's another thing about writing presentations in HTML or code, it helps you
concentrate on what's really important instead of trying to cram as much text
as possible on a slide. Each transition, effect or image you have to
concentrate on rather than just clicking a few menu options.

Overall, I'd recommend trying reveal.js, it's probably not for everyone but I
am sure it fits many peoples needs.
