---
layout: post
title: Designing a Comment System
tags: [blog, comments, design]
---

In my [previous post]({{ site.baseurl }}{% post_url 2019-05-09-comments-on-static-blog %})
I mentioned one possible solution for adding comments to my blog using the 
built in support for data files in Jekyll. This approach was pioneered by 
[Damien Guard](https://damieng.com/blog/2018/05/28/wordpress-to-jekyll-comments).  
In this post I hope to have a crack at designing such a system myself and 
implementing it.

## What do I want?

My first step in designing this comment system will be to decide what my goals 
are. 

* Foremost I want to allow people to leave comments on my blog (obviously)
* Adding comments should be relatively easy
  - The format they are in should be common, I am leaning toward Markdown as
    that is the common format used by Jekyll and is commonly used on sites such 
    as Reddit
* I want to have to curate all the comments coming in and approve them if they 
  seem legitimate 
  - I've had experience in the past when running Wordpress blogs where there 
    was a lot of spam or irrelevant comments that would be nice to filter out
  - Manual approval would likely be fine for me since my blog is low traffic
  - I could still augment approval so that obvious spam comments can be 
    filtered out automatically
  - Being able to block certain known offenders would be a nice feature as 
    well; obviously this is non-trivial but a simple IP blacklist could help
  - Using a [captcha](https://developers.google.com/recaptcha/) would obviously 
    be advantageous or a 
    [honeypot](https://haacked.com/archive/2007/09/11/honeypot-captcha.aspx/) 
    style captcha
  - Browser fingerprinting could be another technique to detect when many 
    requests come from the same source
* I want to preserve comments in a format that is easy to store, process and 
  potentially migrate
  - In addition to this, the comments should be stored in a static way that is 
    in-keeping with Jekyll's general approach
* I want to allow users to have an avatar if they desire it
  - Gravatar is quite popular and would be nice to support
  - Twitter profiles may be useful to support
  - GitHub profiles again would be useful to support
* The comment system should be relatively lightweight
  - By this I mean there shouldn't be too many moving parts to it and should 
    not require any heavy systems be used. 
  - I am thinking of running this on an EC2 instance or as AWS Lambda functions
    so ideally nothing should be process intensive

That's quite a few things I want but it is fairly doable.

Some drawbacks of such a design are:

* No guarantee that commenters are who they say they are
  - This extends further in that a multiple comments do not guarantee that they 
    are from the same person. In a way this is much like a traditional 
    guestbook on older websites
* Comments will take time to appear on the website
  - Since they will be merged into the blog via GitHub they will take a 
    non-trivial amount of time to be approved
  - While waiting for a comment to be approved a user may not realise and 
    attempt to leave another

Overall I am willing to live with these drawbacks, at least for the moment.

The comment system boils down to the following kind of top level flow:

<img alt='Simple system diagram' src='{{ "assets/comment-system/simple-top-level.svg" | absolute_url  }}' class='blog-image' />

1. The user reads a post from the blog
2. The user decides to leave a comment
3. The comment system determines if the comment should be allowed and updates
   the blog

This diagram does simplify parts of the design like approving the comments, 
however this could be seen as being outside of the current scope since it 
would be an external process.

## Some Prototyping

I often find it helpful to work through and prototype some ideas roughly before 
implementing them properly. 

One such prototype that is, in my opinion, always helpful is thinking about 
what kind of inputs and outputs a system will use and produce.  
So in this example a comment might look something like the following (as JSON 
for ease of reading):

```json
{
  "uuid": "UUID",
  "post": "post-id or permalink",
  "displayName": "User display name",
  "avatar": "URL to an avatar",
  "webLink": "a URL provided",
  "comment": "markdown comment"
}
```

Some of these could be optional. I might also want to include a client 
generated date with the data if I want to be able to show when this comment was
posted.

<p class='message'>
You might notice I included a UUID in my fields, I find these useful for use as
correlation IDs during debugging of a system.
</p>

So this is the data provided for the comment but there will also be some 
additional data associated with the comment request:

* Time and date of the request
* Source of the request (IP address etc.)
* Browser metadata and headers

This data could all be used in conjunction with the user generated data, 
especially the data and time.
