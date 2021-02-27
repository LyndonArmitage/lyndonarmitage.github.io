---
layout: post
title: Staticman Comments
tags: [blog, comments]
---

As of now this blog finally has comments, courtesy of
[Staticman](https://staticman.net/)!

Way back in 2019 I wrote 2 articles on adding comments to a static
website/blog.
One [detailed a general design]({% post_url 2019-05-09-comments-on-static-blog %}),
and to my surprise a similar design had been implemented in
[Staticman](https://staticman.net/), a project specifically designed to enable
you to add content to a static site via pull requests on Git repositories.

I won't detail the exact steps I took but it wasn't altogether difficult.

I opted to install Staticman on a VPS I manage rather than Heroku, hooking it
up to GitHub was relatively simple although there was a hiccup in understanding
which way it should be hooked up in (there are 3 options on the help page),
there's a
[PR](https://github.com/eduardoboucas/staticman/issues/367#issuecomment-660312796)
on the actual Staticman code to improve these docs to avoid such an issue.

The VPS I am using is the lowest tier on
[DigitalOcean](https://m.do.co/c/f024e981a0f8) and have setup Nginx & Certbot
to make sure Staticman is running using a TLS certificate so none of your
comments are sent in the open.

Additionally the example Staticman config shows how to hash a field with MD5,
something I am doing to your email addresses so that they are not stored as
plain, scraping friendly strings in my repository.  
Using MD5 to hash your emails also allows me to hook up with
[Gravatar](https://en.gravatar.com/site/implement/)
eventually since MD5 is how they encode your email address for delivery of
profile images.

Here's an example of what comments look like in code:

```json
{
  "_id":"9b6c0050-78f1-11eb-85dc-81d7eb0ada60",
  "name":"Lyndon",
  "email":"4d3efb98c1d9c26b1c98402dcf78499a",
  "url":"https://lyndon.codes",
  "message":"This is a test comment for you to all see.\r\n\r\nNotice the formatting is probably not quite right yet.\r\n\r\nHowever I ___already___ support `markdown`!",
  "date":1614426465
}
```

So far the commenting dialog is very basic, it even navigates you away to the
response JSON right now. I'll be trying to improve that quickly with some nice
HTML and JavaScript however I want to avoid heavy libraries like JQuery.

Comment away!

