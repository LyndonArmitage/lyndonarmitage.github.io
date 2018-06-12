---
layout: post
title: Forced use of HTTPS on Blog
---

Quick update to this blog.  
I have configured and forced the use of [HTTPS](https://en.wikipedia.org/wiki/HTTPS).

Previously I started to look into this but had forgotten about it until a recent 
[blog post by Scott Helme](https://scotthelme.co.uk/https-anti-vaxxers/) reminded
me of just how important HTTPS is. For more information on why HTTPS should be
the default for all websites I suggest this link: 
[https://doesmysiteneedhttps.com/](https://doesmysiteneedhttps.com/)

This site is hosted on GitHub pages and uses Jekyll as a static site template.
Enabling HTTPS was simple enough, below is a list of useful links in case anyone 
struggles:

* [https://blog.github.com/2018-05-01-github-pages-custom-domains-https/](https://blog.github.com/2018-05-01-github-pages-custom-domains-https/)
* [https://help.github.com/articles/setting-up-an-apex-domain/](https://help.github.com/articles/setting-up-an-apex-domain/)

The most annoying parts were waiting for DNS entries to update and then editing 
files in my Jekyll settings to make sure `https://` was used instead of `http://`
where appropriate.

In other news I have noticed I need to fix some formatting in my previous post
so it looks good on smaller devices, unfortunately I did not have Jekyll running
on the machine I wrote that post on so could not preview the post before publishing.
