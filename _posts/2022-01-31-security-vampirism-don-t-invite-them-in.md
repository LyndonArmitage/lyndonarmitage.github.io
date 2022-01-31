---
layout: post
title: 'Security &amp; Vampirism: Don''t Invite Them in'
tags:
- security
- software
- programming
- short
date: 2022-01-31 11:57 +0000
---
In an old talk by Kevlin Henley he made an observation on an effective
programming habit through the use of a
[vampire analogy](https://youtu.be/ZsHMHukIlJY?t=2259). The analogy went
something like this:

> What's the best way to prevent a vampire from preying on you in the night?  
> Don't invite them in.

In the talk he was speaking about how to prevent many common coding issues via
the judicious use of scoping, proper method visibility and encapsulation.
Briefly, in Java (and other OOP languages) this is normally done by using the
right access modifiers: `private`, `protected`, `public` and `default`. Some
languages go further and have more granular access modifiers.

When it comes to security at a higher level of abstraction you should take a
similar approach. Accounts should have the minimum level of credentials/rights
to get their job done. With databases and Data Engineering this often amounts
to using read-only accounts as much as possible, limiting the tables they have
access to and, if possible, even the columns they can access. Even if you can't
get down to that level of granularity on your accounts you can always opt to
not pull in sensitive information into your Data System, or if you do perform
some one-way hashing operation on it that renders it difficult or impossible to
decode the sensitive information.

This falls neatly inline with GDPR and other privacy and security requirements.
After all, you can't expose sensitive customer data if the data does not exist
in your system, you haven't invited it in.

<p class='message'>
This kind of approach is known as the
<a target='_blank' href='https://en.wikipedia.org/wiki/Principle_of_least_privilege'>
Principle of Least Privilege(PoLP)</a> and is widely applied across the IT
Industry.
</p>
