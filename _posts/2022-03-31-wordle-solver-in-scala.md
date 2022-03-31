---
layout: post
title: Wordle Solver in Scala
tags:
- game
- wordle
- scala
- code
- programming
- puzzles
date: 2022-03-31 14:15 +0100
---
With the basic
[Scala implementation of Wordle]({% post_url 2022-03-30-wordle-in-scala %}) 
out of the way in my last post I thought it
might be a fun activity to create a Wordle solver/helper in a similar way. I
like to avoid using such things on real world puzzles as they suck the fun out
of them but writing them and testing them is fun in and of itself, so lets get
started.

First, just like Wordle, I need a word list to use as a dictionary of possible
guesses. If possible this dictionary should match the word list used by the
Wordle implementation I am testing against (which it happens to do since I made
the list).

Next I need a way of representing the solution space I am searching through.
Thankfully, Wordle is a pretty simple solution space as all I need to keep
track of are:

* Whole guessed words
* The validity of specific letters in each position of the word

I represent this with a simple set of case classes:

```scala
sealed abstract class Validity
case object Valid extends Validity
case object Invalid extends Validity
case object WrongPosition extends Validity

case class LetterValidity(
    letters: Set[Char] = 'a'.to('z').toSet
) {
  def remove(c: Char): LetterValidity = {
    copy(letters = letters.filterNot(_ == c))
  }

  def removeAll(chars: Set[Char]): LetterValidity = {
    copy(letters = letters.removedAll(chars))
  }
}

object LetterValidity {
  def apply(c: Char): LetterValidity = LetterValidity(Set(c))
}

case class WordValidity(
    guesses: Seq[String] = Seq.empty,
    letters: Seq[LetterValidity] = Seq.fill(6)(LetterValidity())
)
```

The `LetterValidity` class is mostly a wrapper around a set of characters with
some convenience methods. The `WordValidity` encompasses a list of all previous
guesses and a sequence of the `LetterValidity` objects for each letter/column
in the word. I've initialised these all to sensible starting values.

Now I need to decide how the user will interact with this program. I've settled
on them first typing in their guess, then typing in some symbols to represent
how valid it was according to Wordle:

| Symbol | Validity       |
| ------ + -------------- |
| x      | Invalid        |
| +      | Valid          |
| ~      | Wrong Position |

I parse the input from a user into the above types using a simple method:

```scala
def parseLetters(
    word: String,
    validityString: String
): Seq[(Char, Validity)] = {
  validityString.zip(word).map { case (c, letter) =>
    (
      letter,
      c match {
        case 'x' => Invalid
        case '+' => Valid
        case '~' => WrongPosition
      }
    )
  }
}

```

This returns a simple sequence of tuples containing the letter and how valid it
is.

Now comes the tedious bit, solving the problem. I will paste the code and
explain what it is doing after. I've again opted to use a tail recursive
function since Scala excels at these and it makes programming easier:

```scala
def main(args: Array[String]): Unit = {
  if (args.length < 1) {
    println("arg 1: should be word list file")
    return
  }

  val words =
    mutable.ListBuffer.from(Random.shuffle(File(args(0)).lines.toSeq))
  println(s"Word list of ${words.size} loaded")
  val state = WordValidity()
  guess(words, state)
}

@tailrec
def guess(words: mutable.ListBuffer[String], state: WordValidity): Unit = {
  println("Enter guess:")
  val wordGuess = scala.io.StdIn.readLine()
  println(
    "Enter letter validity, x means not present, + means correct, ~ means present but wrong place:"
  )
  val letterValidity = parseLetters(wordGuess, scala.io.StdIn.readLine())

  val newGuesses: Seq[String] = state.guesses.appended(wordGuess)

  val initialUpdated =
    letterValidity.zip(state.letters).map { case ((c, validity), letter) =>
      validity match {
        case Valid         => LetterValidity(c)
        case Invalid       => letter.remove(c)
        case WrongPosition => letter.remove(c)
      }
    }

  val invalidChars = letterValidity
    .filter { case (_, validity) => validity == Invalid }
    .map(_._1)
    .toSet

  val wrongPositionChars = letterValidity
    .filter { case (_, validity) => validity == WrongPosition }
    .map(_._1)
    .toSet

  val updated = initialUpdated.map { validity =>
    validity.removeAll(invalidChars)
  }

  // remove the guess
  words -= wordGuess
  alignWords(words, updated, wrongPositionChars)

  println(s"${words.size} words remain")
  words.take(10).foreach(println)

  if (words.size == 1) {
    println(s"word is: ${words.head}")
  } else if (words.isEmpty) {
    println("No matching word")
  } else {
    guess(words, WordValidity(newGuesses, updated))
  }
}

def alignWords(
    words: mutable.ListBuffer[String],
    valids: Seq[WordleHelper.LetterValidity],
    wrongPositionChars: Set[Char]
): Unit = {

  words
    .filterInPlace { word =>
      word
        .zip(valids)
        .count { case (c, validity) =>
          validity.letters.contains(c)
        } == word.length
    }
    .filterInPlace { word =>
      wrongPositionChars.intersect(word.toSet).size == wrongPositionChars.size
    }
}
```

This is a long bit of code so let's go through it from top to bottom:

In the `main` method I am reading the whole word list into memory and shuffling
it about, initialising the state and calling the `guess` function. I put the
words into memory since they will all be looked up and manipulated to some
degree.

Within the `guess` method I read in both the guess and how valid it was. I add
the guess to a list of previous guesses if there were any. Then I do an initial
pass on the sequence of `LetterValidity` objects I have and adjust them in
accordance to the user's input. I then do 2 further passes on the user's
validity information and create 2 sets, one containing all the invalid
characters and another containing all the characters in the wrong positions. I
use this first set of invalid characters to further adjust the `LetterValidity`
objects I will be using in the next iteration of this algorithm. Next I remove
the guess from my word list and execute the `alignWords` function, providing it
with the words list, the updated `LetterValidity` objects and the list of wrong
positioned characters.

In the `alignWords` method I perform 2 filters in place on the list of words.
First I remove all words that do not match the `LetterValidity` objects, and
finally I remove all words that do not contain the wrongly positioned
characters.

Returning to the `guess` method I output the amount of remaining words along
with 10 of them to aid in guessing. If there is 1 word left then I exit since
that must be the answer. If there's no words left then either the user has put
some bad input in or the word list I am using is incomplete. And finally if
there are still many more guesses to be had I run the `guess` function again
with some updated state.

Let's see how this code fairs on Wordle!

My first guess will be the word "adapt":

<img
  alt='Wordle guess'
  src='{{ "assets/wordle/1st-guess.png" | absolute_url  }}'
  class='blog-image'
/>

The first 4 letters are invalid and the 5th is in the wrong place so I enter
this into the solver:

```text
Enter guess:
adapt
Enter letter validity, x means not present, + means correct, ~ means present but wrong place:
xxxx~
1129 words remain
newts
timer
north
turms
metol
twine
motts
broth
gytes
visto
```

I choose to use the word "timer" next and enter the results into my solver:

<img
  alt='Wordle guess'
  src='{{ "assets/wordle/2nd-guess.png" | absolute_url  }}'
  class='blog-image'
/>

```text
Enter guess:
timer
Enter letter validity, x means not present, + means correct, ~ means present but wrong place:
~xx~x
148 words remain
newts
kythe
ctene
kents
suety
ketol
coste
bents
fytte
butle
```

Not bad, I try "suety":

<img
  alt='Wordle guess'
  src='{{ "assets/wordle/3rd-guess.png" | absolute_url  }}'
  class='blog-image'
/>

```text
Enter guess:
suety
Enter letter validity, x means not present, + means correct, ~ means present but wrong place:
+x~~x
5 words remain
stole
seton
stone
stove
stoke
```

Fantastic! I am down to 5 words left with 3 guesses to go. I try "stone":

<img
  alt='Wordle guess'
  src='{{ "assets/wordle/4th-guess.png" | absolute_url  }}'
  class='blog-image'
/>

```text
Enter guess:
stone
Enter letter validity, x means not present, + means correct, ~ means present but wrong place:
+++x+
3 words remain
stole
stove
stoke
```

That left me with 3 words left and only 1 character to guess. I try "stove" and
win with 1 guess left to spare!

<img
  alt='Wordle guess'
  src='{{ "assets/wordle/5th-guess.png" | absolute_url  }}'
  class='blog-image'
/>

This is obviously not a foolproof solver since in the last stage I could have
still failed since all 3 words differ but the solver was able to get me to
them!

There's room for further enhancement, especially around suggestions of what
word to guess next. For example, if desired I could scan the remaining
dictionary/word list and suggest the word likely to eliminate the most words.
This would be the word with the most letters in common with all other words,
and would help cut down on the amount of guesses needed.
