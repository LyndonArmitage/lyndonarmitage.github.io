---
layout: post
title: 'Advent of Code 2024: Summary of Days 7 to 12'
tags:
- coding
- programming
- advent of code
- python
- 2024
---

This page serves as the second part of a summary of my experience with [Advent
of Code 2024](https://adventofcode.com/), covering days 7 to 12. For the first
6 days see my [previous post]({% post_url
2024-12-06-advent-of-code-2024-summary-days-1-to-6 %}).

As mentioned previously and in the Advent of Code
[FAQ](https://adventofcode.com/2024/about), I won't be including the puzzle
text or raw inputs in this post, and I'll be referring to each part of the
question as Part A and Part B.

## Day 7

Starting of the Saturday, [Day 7](https://adventofcode.com/2024/day/7) was on
par in difficulty with the previous days. It involved discovering which
operators would result in a given value and adding them together.

My approach to Part A of this question involved creating a Python
[enum](https://docs.python.org/3/library/enum.html) to hold the possible
operators and implement them in a single place. The first 2 operators, addition
and multiplication, were trivial to implement. Python's excellent standard
library made it relatively easy to generate the possible operators for each
line of input using
[itertools.product](https://docs.python.org/3/library/itertools.html#itertools.product).

Part B added a single new operator, concatenation. Again the flexibility of
Python meant I could add this a simple operation using strings
`int(f"{a}{b})"`. Of course, this is likely slower than doing the equivalent
math. I will revisit this to optimise it further.

## Day 8

[Day 8](https://adventofcode.com/2024/day/8) came out on a Sunday.
Unfortunately, I was very busy that day so I only managed to look at the
problem in earnest in the evening. With my tired eyes I still managed to
complete Part A, but the wording on both questions proved a little difficult to
decipher at the time.

Again, [itertools](https://docs.python.org/3/library/itertools.html) really
helped with these challenges. This time it was the `combinations` function that
proved useful in getting the unique combinations of antennas.

Part A was relatively simple once you understand the problem. Simply find the
difference between the two antennas points and project a point from each in
either direction. I struggled to get the correct answer to this briefly, as I
made a mistake when loading the puzzle input and increased the width of my grid
by a single digit! This didn't break the example given, but with the actual
puzzle input I had it resulted in 14 extra antinodes appearing along the
rightmost column.

After some well earned rest, I was able to tackle Part B. This just consisted
of creating antinodes at every interval along the lines produced by two
antennas. This interval is the distance between the two antennas.
