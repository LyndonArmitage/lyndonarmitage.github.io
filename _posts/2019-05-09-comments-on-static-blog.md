---
layout: post
title: Comments on a Static Blog
tags: [blog, comments]
---

I have been considering adding comments to my blog for a little while now.

Other people with static blogs built on Jekyll tend to use 
[Disqus](https://disqus.com/) for their comments.
Disqus is a purpose built third-party plugin for embedding comments 
in websites and works quite well.  
However as Victor Zhou outlined in his 
[blog post](https://victorzhou.com/blog/replacing-disqus/) Disqus is actually 
a very heavy plugin that makes a lot of external requests. It is also closed 
source and powered by adverts (at least at the free tier).  
Victor actually recommend using an alternative in his blog post called 
[Commento](https://commento.io/) which is much more lightweight (in size and 
requests), open-source, values privacy and can even be 
[self hosted](https://docs.commento.io/installation/self-hosting/) if desired.

When looking for alternatives to Disqus I also came across a 
[blog post](https://haacked.com/archive/2018/06/24/comments-for-jekyll-blogs/) 
by Phil Haack mentioning quite a cool solution that 
[Damien Guard](https://damieng.com/blog/2018/05/28/wordpress-to-jekyll-comments) 
mentioned to him; using [Jekyll data files](https://jekyllrb.com/docs/datafiles/) 
and pull requests on GitHub to make a comment system that is static.  
This approach seems quite cool in my opinion and would a nice self contained 
project to have a go at implementing.

Stay tuned to see what kind of solution I go with. I may well opt to continue 
not having any comments on my blog.
