---
layout: post
title: 'Advent of Code 2024: Summary of Days 13 to 18'
tags:
- coding
- programming
- advent of code
- python
- 2024
---

This page serves as the third part of a summary of my experience with [Advent
of Code 2024](https://adventofcode.com/). It coverss days 13 to 118.

For the first 6 days see my [first summary]({% post_url
2024-12-06-advent-of-code-2024-summary-days-1-to-6 %}), for days 7 to 12 see
[my second post]({% post_url
2024-12-13-advent-of-code-2024-summary-of-days-7-to-12 %}).

 As mentioned in both my previous posts, I've tried to avoid including full
 puzzle inputs and text in this post as per the Advent of Code
 [FAQ](https://adventofcode.com/2024/about) and I'll be referring to each part
 as Part A and Part B.

### Day 13

The [Day 13](https://adventofcode.com/2024/day/13) challenges revolve around
arcade [claw machines](https://en.wikipedia.org/wiki/Claw_machine). The input
for the questions is 3 lines, the first 2 being what happens when buttons are
pressed and the third being the location of the prize.

The first part has a limit of 100 button presses for each button. This
simplifies any kind of brute force approach, which is how I solved Part A.
However, before even solving this problem, I noted that this could probably be
solved with algebra as it looked like this problem involved finding the
intersection of two lines.

In fact if you plug these values into a graphing calculator like
[Desmos](https://www.desmos.com/calculator), you can find the intersection if
you treat the Xs and Ys each as lines. 

For this input:

```
Button A: X+94, Y+34
Button B: X+22, Y+67
Prize: X=8400, Y=5400
```

Below, the first line describes X and the second describes Y:

```
Line 1: 94x + 22y = 8400
Line 2: 34x + 67y = 5400
```

These produce these lines:

<img
  title='Diagram showing the lines intersecting'
  alt='Diagram showing the lines intersecting'
  src='{{ "assets/aoc2024/day14-lines.webp" | absolute_url }}'
  class='blog-image'
/>

For Part B you need to have been solving this with algebra to get a quick
solution, unless you highly optimise your brute force approach (which I tried
to no avail). I won't go over the details, but Josiah Winslow has a good
explanation of it and the simple way of solving this algebra in his [Day 13
post](https://winslowjosiah.com/blog/2024/12/13/advent-of-code-2024-day-13/).

## Day 14

The [Day 14](https://adventofcode.com/2024/day/14) was a fun puzzle. Part A
involves simply simulating a bunch of robot as they move around a space for 100
seconds. My input results in the following (white pixels are robots):

<img
  title='Animation of Day 14 Part A'
  alt='Animation of Day 14 Part A'
  src='{{ "assets/aoc2024/day14-parta.gif" | absolute_url }}'
  class='blog-image'
/>

Part B stumped me. It pointed out that there was a Christmas Tree that would
appear at some point while the robots were moving.

Initially, I outputted many frames looking for a Christmas Tree by eye to no
avail.

Next, I wrote a heuristic to check each robot in each frame to see if they were
surrounded by neighbours, assuming that this would happen for a Christmas Tree
image. My code worked but was too slow for my liking, so while I let it run, I
begrudgingly opted to look online for some hints, careful to not look at any
full solutions.

I found that, according to
[some](https://www.reddit.com/r/adventofcode/comments/1he88a8/comment/m21ohkp/),
the frames that contain the Christmas Tree contain no overlaps. So I stopped my
running search and wrote a short function to find those frames, and, as luck
would have it, the first frame with 0 overlaps contained my Christmas Tree:

<img
  title='Day 14 Part B Tree'
  alt='Day 14 Part B Tree'
  src='{{ "assets/aoc2024/tree.png" | absolute_url }}'
  class='blog-image'
/>

Now, I am not certain this will hold true for all inputs, so doing a different
kind of search like my original idea might be a better way to find this tree.

## Day 15

[Day 15](https://adventofcode.com/2024/day/15) was Sundays challenge.
Unfortunately, given it is Christmas time, I didn't get a chance to look at the
challenge until Monday the 16th.

Both parts involve simulating a robot pushing boxes around a warehouse. The
input consisted of a map of the warehouse and then the moves the robot makes.

These were fun puzzles to solve. Part A was very simple, as it asks you to run
simulate the movements then sum up the "GPS" positions of each box.

My input data was 500x500 tiles large. The overall movement looked like the following video.

<video 
  class='blog-image' 
  autoplay 
  muted 
  controls 
  loop 
  disablepictureinpicture
  poster='{{ "assets/aoc2024/day15-0.png" | absolute_url }}'
>
  <source src='{{ "assets/aoc2024/day15-parta.mp4" | absolute_url }}' type='video/mp4'>
Your browser does not support the video tag so below is a still image:
<img
  title='Day 15 input'
  alt='Day 15 input'
  src='{{ "assets/aoc2024/day15-0.png" | absolute_url }}'
  class='blog-image'
/>
</video>

Black tiles are the walls, red tiles are the boxes and the blue tile is the
robot. The input had a lot of movements, you can see by the over 5 minutes run
time.

Part B was similar, except this time the map and boxes have expanded to be
twice as wide.