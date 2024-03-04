---
layout: post
title: What is Premature Optimisation?
tags:
- programming
- benchmarks
- code
- optimisation
- thoughts
- algorithms
date: 2024-03-04 11:22 +0000
---
As programmers we're often taught to take certain things for granted, when it
comes to performance. Likewise, we often throw around the Sir Tony Hoare quote,
made famous by Donald Knuth: "Premature optimisation is the root of all evil."
But what is premature optimisation?

It can be a bit tricky to define exactly what is meant by "premature
optimisation", since a lot of what programmers do is essentially optimisation.
Generally, you should consider it **spending large amounts of time on something
that will bring in negligible returns over the course of the life of your
software**.

For example, if you're writing a script to scan a handful of local files only
you yourself will be running a handful of times, it makes little since to spend
time perfecting some perfect process that runs in exactly `O(n)` time rather
than `O(10n)` time. Sure, the process might be 10 times slower, but the time
spent optimising it could well take longer than the original version would ever
run.

However, what counts as "premature optimisation" is always situational. If, in
the above example, the "handful of local files" amounts to something like
100,000 files that `O(10n)` might actually amount to a lot more time than
`O(n)`. If in the original version it takes 1 second to scan a file, the
100,000 second runtime amounts to almost 28 hours, whereas the optimised version
could take as little as 3 hours.

So we can say that context matters, when it comes to defining what is and isn't
"premature optimisation". Likewise, we can infer that the often used rule of
thumb of eliminating the multiplier from your Big O notation estimates can
delude you as to where optimisations might be needed, if the multipliers or
value of `n` are large enough.

So the question remains, **what is premature optimisation?** How can we tell
when a piece of code will benefit from optimisation, or when it will be mostly
an exercise in [yak shaving](https://en.wiktionary.org/wiki/yak_shaving)?

We know context is important, but what context in particularly? The answer here
depends on the program you're writing, but generally you should ask yourself a
few questions to zone in on the areas that might actually need optimisation and
find those where such effort might be a waste:

* What parts of the program (if any) are time critical?
* How often will this program be run?
* How long will this program be used for?
* Where is my program spending most of its time?

If your program is going to be seldom run, and the timeliness of results is of
little consequence, then it is inherently a waste of time spending hours
optimising small parts of it.

On the other hand, if your program is only going to be run once, but it is
critical that you get timely results it may well be worth spending a few hours
optimising parts of it.

Likewise, if your program is going to be run very often, and even if the
results don't need to arrive incredibly quickly, it may still be worth the
effort optimising parts of it; to both reduce processing time and costs
associated with the often running program. These costs can even include the
power costs associated with running the software.

The last question on this list assumes you've already written your software.
It's often given advice that you should get your program working then worry
about optimising it. This isn't always possible, or preferable as some
decisions made when writing software may require a lot of unpicking to
alter and optimise.

Nevertheless, if you do already have your program complete then **benchmarking
and measuring it are key in finding out what the hotspots are for performance
issues**. When combined with answering the other questions, this can give you a
sharp focus on what actually slows down your software without any assumptions
or guess work being done.

Even if you have yet to fully author your software, you can still make educated
guesses as to where your program will be spending the lion's share of its
time:

Focus in on where it accesses external resources, like files, the network and
devices first. These are often the source of most latency in any system, and in
some situations introduce unavoidable delays that render much optimisation
effort moot.

Then you can move onto the heavily repeated sections of code that make use of
looping structures and recursion. These are what give you hints into the Big O
of various parts of your program.

Finally, you can investigate the data structures and algorithms you are using:

There can be wild differences when it comes to how collections function in both
storage and access patterns. For example, in Scala you default to using
immutable collection types. These work well in a lot of instances as you can
apply functional operations to them sequentially and in parallel. However, if
you're growing an immutable list or sequence, what you are actually doing is
creating a brand new instance of that list combined with the added elements.
These operations are vastly more costly to do than using some kind of mutable
collection that grows its own internal buffer (like an array backed list) when
items are added. So you should choose your data structures carefully and
consider what they are doing conceptually under the hood.

Likewise, some algorithms are inherently slow. The quintessential examples of
this, often taught at university, are sort and search algorithms. Something
that is not highlighted as often are ways to work around or with an algorithms
limitations. Often you're taught to just "pick the right algorithm", which you
cannot always do, as there isn't a "right" answer, **all choices have
trade-offs**. Partially sorting on insertion, for instance, can help skew some
sorting algorithms towards their best-case complexities to such an extent that
they are worth picking over another algorithm whose worst-case complexity is
better.

It's important to **not let perfect be the enemy of good** however. This is why
any efforts made in optimisation must be tempered with an understanding of what
is actually important in the context of the software being written. We can find
areas of slow code that just don't matter in the grand scheme of the running
program, areas that are ripe for spending hours optimising, but these are at
best interesting future learning opportunities. For example, it doesn't matter
that it takes 30 seconds to perform a bunch of operations on an arriving file,
if the file only arrives once every hour. It might in the future, but for now
it would be **premature** to focus on reducing the time to process that
file.

The call to avoid "premature optimisation" is often used as an excuse to avoid
writing performant code. Something that has become all too much the norm on the
web in recent days. Over the last 20 years, websites have both bloated in size
and load times, even in relation to their increased interactivity and content,
with the excuse often being [Moore's
law](https://en.wikipedia.org/wiki/Moore's_law). Likewise, developers often opt
to lean heavily on abstractions and library provided structure to avoid
deliberately thinking about performance, using the avoidance of "premature
optimisation" as a mantra. It's this **deliberate thought** that should be
cultivated rather than avoided. Rushing to solve a problem results in a sub-par
solution. Good examples of this can be seen when people focus on solving
[LeetCode](https://leetcode.com/)-like problems in quantity, rather than
cultivating quality answers and an understanding of the tools (programming
language and its ecosystem) at their disposal.

Hopefully I've shed some light on my thoughts on what "premature optimisation"
is, how to avoid it, and how to actually optimise code in a way that isn't
"premature".
