---
layout: post
title: Comments Update
tags:
- blog
- comments
- staticman
date: 2021-04-26 17:00 +0100
---
Since 2021/02/27 my blog has had comments enabled courtesy of Staticman.
Unfortunately it seems that the only comments I get are spam so I am torn as to
whether to continue enabling comments or to remove them.

Just to be clear, I was not expecting to get hundreds of comments on my posts,
far from it! I was however hoping to get the occasional insightful one from
time to time.

Currently having comments doesn't cause me too many headaches; every so often I
check my GitHub for pull requests that comments come in as and delete the spam
comments. But today I had to wrestle with a Ruby update breaking Jekyll on my
local machine and it made me question whether I even need to use Jekyll to host
my website and blog.

I could in theory resort to a simple Makefile to produce the HTML for all my
blog posts and RSS feed. It would not be super complex; all my posts are
written in Markdown and I can easily use `pandoc` or another tool to convert
them to HTML and embed them in a template.  
I'd lose out on all the Liquid templating that is supported by Jekyll but I
mainly use that in the comments section, archive page, feed and a little bit in
the layouts. All for things that I could more easily script with the shell. In
actual fact some of what I do might be even better done in the shell as it
would avoid some of the limitations of Liquid.

Overall losing comments might *not* be the worst thing in the world. If I want
conversation over an idea I think it might be better to do so on a dedicated
platform for that like Mastodon or even email. It might even be more in keeping
with the Unix philosophy!
