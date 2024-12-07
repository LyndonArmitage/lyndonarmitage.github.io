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
