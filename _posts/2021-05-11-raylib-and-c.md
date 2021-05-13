---
layout: post
title: Raylib and C
tags:
- raylib
- c
- programming
date: 2021-05-11 17:56 +0100
---
Recently I wanted to refresh my C programming skills and was on the lookout for
a library or framework for getting graphics onto the screen while doing so and
I stumbled upon the [Raylib](https://www.raylib.com/) library.
It suited the bill perfectly.

Previously I had a quick play with the X windows libraries directly in C but I
fancied something slightly higher level but also something different to what I
have used before [SDL](https://www.libsdl.org/) and
[SFML](https://www.sfml-dev.org/), so I did some searching and found Raylib
which is a fantastic little library designed around writing simple video games
in C and C++.

The library is specifically written in C which is great as I wanted to
avoid all the extra C++ features that I haven't touched in many years, and also
wanted to not be beholden to an object orientated style since I have been
spending a lot of my time programming in Scala and Kotlin in recent years.

Raylib provides everything you need without any additional libraries which is
very nice. It has an easy to use API for building simple applications, a tonne
of [examples](https://www.raylib.com/examples.html), and even a
[cheat sheet](https://www.raylib.com/cheatsheet/cheatsheet.html) so you don't
have to spend your time hunting for functions.

With all this I set out and made 2 quick applications in C using Raylib:

The first was a simple
[Conway's Game of Life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life)
[Implementation](https://github.com/LyndonArmitage/raylib_gol):

<img alt='Conways Game of Life Screenshot' title='Conways Game of Life Screenshot' src='{{ "assets/raylib/gol.png" | absolute_url }}' class='blog-image' >

The second was a
[Galaxy Generator](https://github.com/LyndonArmitage/raylib_galaxy):

<img alt='Generated Galaxy Image' title='Generated Galaxy Image' src='{{ "assets/raylib/galaxy.png" | absolute_url }}' class='blog-image' >

I have created both before in other languages and frameworks and find that the
Game of Life is an excellent toy program to test a framework with. The galaxy
generator matches about the same amount of code in a higher level language like
Kotlin which impressed me!

Overall if you do some C programming or want to have a play with a framework
for building games or just graphical applications in C I'd say give Raylib a
look into!
