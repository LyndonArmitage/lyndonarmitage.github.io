---
layout: post
title: 'Advent of Code 2024: Summary'
tags:
- coding
- programming
- advent of code
- python
- 2024
---

This page serves as a summary of my experience with [Advent of Code
2024](https://adventofcode.com/). A mentioned in my [original post]({% post_url
2024-12-01-advent-of-code-2024 %}), I decided against forcing myself to learn
another programming language as well as opted not to post an article for each
challenge.

As per the [FAQ](https://adventofcode.com/2024/about), I won't be including the
puzzle text or raw inputs in this post. Please use the links to the questions
for context.

The notes within this article could potentially be helpful for those getting
stuck on questions, if used as hints. I will eventually publish my solutions as
a repository.

## Day 1

As mentioned in my original post, the [Day
1](https://adventofcode.com/2024/day/1) challenges were not difficult. They
require you to be comfortable sorting lists and comparing values.

I opted to insert data into the 2 lists in order, rather than loading them and
calling a sort function. This meant iterating over the lists for each entry.

Part A was done by simply zipping the two collections together and comparing
the values.

Part B was done with some nested loops. Additionally, I cached the scores for
each unique number to avoid needless extra loops.

## Day 2

[Day 2](https://adventofcode.com/2024/day/2) was a similar level of difficulty
to Day 1.

Part A was very simple,
checking if ascending or descending was simple, and the difference was likewise
trivial.

Part B is a little more involved, but I ended up opting to run the same
algorithm as Part A on multiple versions of the input that omit single entries,
making it relatively simple.

It is likely possible to do Part B in a single loop rather than by running the
solution to Part A multiple times, but in the interest of speed and readability
I opted not to do this.
