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

## Day 9

So [Day 9](https://adventofcode.com/2024/day/9) seemed like a spike in
difficulty compared to the previous days. These challenges invoked memories of
running disk defragmentation software in the early 2000s.

For both parts, you take the puzzle input and decode it to represent
a disk containing files and free space, and then operate on it:

<img
  title='Visualisation of expanding input data'
  alt='Shows input example `2333133121414131402` becoming output
  `00...111...2...333.44.5555.6666.777.888899`'
  src='{{ "assets/aoc2024/day9-expand.webp" | absolute_url }}'
  class='blog-image'
/>

Then the objective of Part A was to move blocks of data so they are all next to
each other, before finally calculating a simple checksum.

<img
  title='Visualisation of Part A data moving'
  alt='Diagram showing data moving in Part A'
  src='{{ "assets/aoc2024/day9-parta.webp" | absolute_url }}'
  class='blog-image'
/>

Initially, my solution to Part A involved me converting the input string into
an expanded string, similar to how the examples were explained in the question.
This worked well for the example input, as it only included 10 total unique
IDs, but when ran on the real puzzle input my code was faulty.

Eventually, after much time spent frustrated, I looked to the internet for some
hints, careful to avoid any full solutions. It didn't take long to see that
others had made a similar mistake. In the actual puzzle input there are many
more unique IDs than the 10 in the example. As a consequence of using a string
the IDs that are greater than 9 were being treated as multiple IDs between 0-9.

<img
  title='Visualisation of decoding issue'
  alt='Diagram showing the decoding issue when using strings for input with
  more than 10 unique IDs'
  src='{{ "assets/aoc2024/day9-decoding-issue.webp" | absolute_url }}'
  class='blog-image'
/>

Thankfully, with the problem known, it was simple to rectify, instead of
creating a new expanded string I instead stuck with a list of either IDs or
`None` entries like so `list[Optional[int]]`.

As anyone who ran disk defragmentation in the past knows, storing all your data
close together is all well and good, but what you really want is like for like
data near each other so you avoid those time consuming seeks. This was the
objective of Part B. I solved this by using a simple algorithm that walked from
the end of the list backward, then when it found a chunk of non-empty data I
would pause and then search from the front of the list for an empty space large
enough for that chunk and move it there. After which the backward search would
continue.

<img
  title='Visualisation of Part B data moving'
  alt='Diagram showing data moving in Part B'
  src='{{ "assets/aoc2024/day9-partb.webp" | absolute_url }}'
  class='blog-image'
/>

This algorithm is relatively slow as it will search for empty space for every
block of non-empty data found. I could improve upon this by keeping track of
both what data was moved and an index of the empty space available.

## Day 10

[Day 10](https://adventofcode.com/2024/day/10) assigns us challenges involving
a [topographic map](https://en.wikipedia.org/wiki/Topographic_map). Thankfully,
the inputs use only the numbers 0-9 to represent various heights. These can be
mapped easily to greyscale.

<img
  title='My input turned into a greyscale image'
  alt='Image version of my input'
  src='{{ "assets/aoc2024/day10-input.png" | absolute_url }}'
  class='blog-image'
/>

Part A requires us to find trailheads and add up their scores. A trailhead is
made from paths on the map. These paths have to start at a value of 0 and end
on a value of 9, with each step only increasing the tile value by 1. In this
challenge we can only move in the cardinal compass directions, i.e. North,
East, South, or West. The trailhead score is the count of 9 height tiles
reachable from its 0 height start.

You can solve Part A with a modified [flood-fill
algorithm](https://en.wikipedia.org/wiki/Flood_fill). Starting at a 0 height,
at each stage you'd be looking for values that are 1 higher up until 9. Scoring
becomes a matter of counting the unique 9-height tiles reached.

Being familiar with pathfinding problems, I noticed you can potentially do some
optimisations to reduce the search space, these were ultimately
unneeded as using the contents of the flood-fill is enough to limit
calculations in both parts.

One optimisation that can be done is in finding the trailheads: You can find
all the starts and ends of possible trails by simply searching for 0 and 9
height tiles on the map, then with these positions, you can create pairs of
potential trail starts and trail ends. Because we can only move 1 value up in
height at a time, we know that any ending points that are further away than 9
steps (0 to 9) cannot possibly be reached. We can even avoid using the proper
2D distance formula to measure this distance because we cannot travel
diagonally.

```py
from math import sqrt
from typing import TypeAlias

XY: TypeAlias = (int, int)

# This is the 2D distance formula
def dist(a: XY, b: XY) -> float:
    return sqrt(pow(b[0] - a[0], 2) + pow(b[1] - a[1], 2))

# This is an approximation we can use
# Since we cannot move diagonally, simple addition works
def taxicab_dist(a: XY, b: XY) -> int:
    return abs(b[0] - a[0]) + abs(b[1] - a[1])
```

As you can see from the examples below the min "taxicab" distance an end tile
can be from a start tile is 1 and the maximum is 9:

<img
  title='Example of possible paths'
  alt='Example of min and max paths'
  src='{{ "assets/aoc2024/day10-parta-distances.webp" | absolute_url }}'
  class='blog-image'
/>

So a modified flood-fill solves Part A, but Part B requires you to keep track
of unique paths, which means each start and end pair can have multiple paths.
Thankfully, our flood-fill from Part A can serve as a way of limiting any
more advanced search.

If we modify our flood filling algorithm to make a note of all the possible
sources a tile can be reach from we end up building a graph.

<img
  title='This is also called a flow field'
  alt='Example showing the flow from a height 9 to 0'
  src='{{ "assets/aoc2024/day10-flow-field.webp" | absolute_url }}'
  class='blog-image'
/>

From this graph we can easily generate all the possible unique paths, solving
Part B.
