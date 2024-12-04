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

## Day 3

[Day 3](https://adventofcode.com/2024/day/3) gets a little harder than the
first 2 days.

These puzzles have you implement a rudimentary parser/interpreter.

Part A was simple enough and can be done with a simple [Regular
Expression](https://en.wikipedia.org/wiki/Regular_expression) like
`mul\((\d{1,3}),(\d{1,3})\)` or by writing a manual string parser.

Part B is a little more difficult as it involves conditional turning on and off
of the previous command. In theory, if you wrote a manual parser, you could do
this on the fly as you parse the instructions. I however opted for an easier,
less efficient approach. I wrote 2 more regular expressions to detect the `do`
and `don't` instructions, and ran all 3 expressions on the input, collected the
output, and sorted them by location. Then I just iterated over the instructions
one at a time, keeping track of the enabled state.

## Day 4

[Day 4](https://adventofcode.com/2024/day/4) was probably on par in difficulty
with Day 3.

The first part was a nice simple wordsearch. I built a data structure
containing all the characters in it, essentially a 2 dimensional array. From
there I looked through each character in all the compass directions for the
search string.

Thanks to the way I structured my code in the first part, the second part
wasn't too hard to achieve as the search code I wrote could be applied to the 4
different X configurations.
