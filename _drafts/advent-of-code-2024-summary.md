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

Part A was done by simply
[zipping](https://docs.python.org/3/library/functions.html#zip) the two
collections together and comparing the values. The diagram below shows how this
works based on the [Scala Visual
Reference](https://superruzafa.github.io/visual-scala-reference/zip/):

<img
  title='Visualisation of Zipping 2 collections'
  alt='Diagram illustrating the zip function: pairs elements from two sequences
  by index, truncating to the length of the shorter sequence, and outputs a
  collection of tuples.'
  src='{{ "assets/aoc2024/zip.webp" | absolute_url }}'
  class='blog-image'
/>

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

<img
  title='There are 8 compass directions'
  alt='Diagram showing the 8 compass directions: north, northeast, east,
  southeast, south, southwest, west, northwest'
  src='{{ "assets/aoc2024/compass-directions.webp" | absolute_url }}'
  class='blog-image'
/>

Thanks to the way I structured my code in the first part, the second part
wasn't too hard to achieve as the search code I wrote could be applied to the 4
different X configurations.

<img
  title='There are only 4 possible X configurations'
  alt='Diagram showing the 4 X configurations'
  src='{{ "assets/aoc2024/4-x-configurations.webp" | absolute_url }}'
  class='blog-image'
/>

## Day 5

[Day 5](https://adventofcode.com/2024/day/5) was the first puzzle whose input
is divided into 2 parts that need parsing. This was very easy since the data is
well formatted and divided by a blank line.

Part A involved filtering the list of rules presented as the first part of the
input to those valid for each list of integers in the second part of the input.
After which you had to verify if the list matched those rules. This is
relatively simple as the rules are formatted as `number1|number2` which means
that `number1` must come before `number2` in the list, which can be checked
with simple nested loops that exit early upon failure.

Part B required you to take the lists that were invalid, and sort them based
on the rules that applied to that list. This was a little more involved, but I
settled on a simple sorting algorithm that did the following:

1. Starting at the back of the list, set the current index to be the last index
   in the list
2. Find the earliest index the current number can be in the list based on the
   rules
3. Shift the current number to the earliest index if it needs to move,
   otherwise move backward in the list and set the current index to 1 less
4. Repeat steps 2 and 3 until the current index reaches -1

This looks something like this animated GIF for the last example given with the
question:

<img
  title='Blue denotes the item being checked, green shows positions that are
  valid, and red shows the items being compared to.'
  alt='An animated GIF showing the above alogorithm'
  src='{{ "assets/aoc2024/day5-partb.gif" | absolute_url }}'
  class='blog-image'
/>

A step-by-step, stationary version of this GIF can be seen
[here]({{ "assets/aoc2024/day5-partb.webp" | absolute_url }}).

Part A could have been solved by implementing the sorting algorithm for Part B
and comparing the 2 outputs. If you did it this way, well done!
