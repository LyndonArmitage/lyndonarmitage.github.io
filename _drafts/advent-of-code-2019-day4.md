---
layout: post
title: Advent of Code 2019 Day 4
tags: [scala, advent of code]
---

This year I have decided to try and do the code challenges on the
[Advent of Code](https://adventofcode.com/) website in Scala and possibly Spark
if needed (or an interesting solution arises).  
These are simple little coding challenges given once per day like an Advent
Calendar before Christmas.

## [Day 4](https://adventofcode.com/2019/day/4): Part 1

This challenge is relatively short so I will include the whole thing below:

> --- Day 4: Secure Container ---
>
> You arrive at the Venus fuel depot only to discover it's protected by a
> password. The Elves had written the password on a sticky note, but someone
> threw it out.
>
> However, they do remember a few key facts about the password:
>
> * It is a six-digit number.
> * The value is within the range given in your puzzle input.
> * Two adjacent digits are the same (like `22` in `122345`).
> * Going from left to right, the digits never decrease; they only ever
>   increase or stay the same (like `111123` or `135679`).
>
> Other than the range rule, the following are true:
>
> * `111111` meets these criteria (double `11`, never decreases).
> * `223450` does not meet these criteria (decreasing pair of digits `50`).
> * `123789` does not meet these criteria (no double).
>
> How many different passwords within the range given in your puzzle input meet
> these criteria?
>
> Your puzzle input is `136760-595730`.

So we need to crack that password! Or at least work out how many combinations
there are.

This is a nice and simple thing to do in Scala:

```scala
val min = 136760
val max = 595730

val fullRange = min to max
```

First we define the minimum and maximum and create a range between them.

Next I want to extract each digit inside each item in the range into a single
number. I actually use a bit of a short-cut to do this:

```scala
def charToInt(char: Char): Int = char.toInt - '0'
```

This method will take a character and assuming it is a number character will
convert it into a matching integer. Combined with a string version of a
candidate password this lets me produce an array of digits with ease like so:

```scala
fullRange
  .map(n => n.toString)
  .map(string => string.map(char => charToInt(char)))
```

Now all we need to do is filter down this big collection of digits to match
the criteria described:

First lets find all the combinations with repeating digits:

```scala
def hasRepeatedDigit(number: IndexedSeq[Int]): Boolean = {
  for (index <- 0 until number.size - 1) {
    val digit = number(index)
    val nextDigit = number(index + 1)
    if (digit == nextDigit) {
      return true
    }
  }
  false
}
```

That's pretty simple and easy.

Next let us filter to just those digits with incrementing or remaining the same
digits:

```scala
def isIncrementingOrSame(number: IndexedSeq[Int]): Boolean = {
  var index: Int = 0
  while (index < number.size - 1) {
    val digit = number(index)
    for (i <- index + 1 until number.size) {
      val testDigit = number(i)
      if (testDigit < digit) {
        return false
      }
    }
    index += 1
  }
  true
}
```

A little more complex but not hard.

Putting these together like so:

```scala
val validPasswords = fullRange
  .map(n => n.toString)
  .map(string => string.map(char => charToInt(char)))
  .filter(hasRepeatedDigit)
  .filter(isIncrementingOrSame)

println(validPasswords.size)
```

Will print out the amount of valid values asked for in part 1!

## Day 4: Part 2

Now part 2 modifies one of the conditions slightly:

> --- Part Two ---
>
> An Elf just remembered one more important detail: the two adjacent matching
> digits are not part of a larger group of matching digits.
>
> Given this additional criterion, but still ignoring the range rule, the
> following are now true:
>
> * `112233` meets these criteria because the digits never decrease and all
>    repeated digits are exactly two digits long.
> * `123444` no longer meets the criteria (the repeated `44` is part of a
>    larger group of `444`).
> * `111122` meets the criteria (even though `1` is repeated more than twice,
>    it still contains a double `22`).
>
> How many different passwords within the range given in your puzzle input
> meet all of the criteria?
