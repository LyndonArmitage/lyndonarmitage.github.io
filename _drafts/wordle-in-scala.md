---
layout: post
title: 'Wordle in Scala'
tags:
- game
- wordle
- scala
- code
- programming
- puzzles
---

The game [Wordle](https://www.nytimes.com/games/wordle/index.html) seems to
have come out of nowhere in recent months and become a favourite among many. In
this post I will show how you can make a game similar to Wordle in Scala.

First off a quick recap of what Wordle is:

<img
  alt='Wordle grid'
  src='{{ "assets/wordle/wordle-example.png" | absolute_url  }}'
  class='blog-image'
/>

Worlde is a puzzle game where you are tasked with guessing a 5 letter word in 6
guesses.  
Each time you guess, you are told which letters you got in the right
place, which ones are present but not in the right place and which letters are
not present.  
If after 6 guesses you don't guess the word then you lose and must wait for
the next word to be generated.

## A Word List

So in order to make our own version of this game we will need a word list. The
actual word list used by Wordle has been [released/leaked
online](https://github.com/tabatkins/wordle-list) but any list of words can
work, in fact, we can make our own word list from some public domain text!

[Project Gutenberg](https://www.gutenberg.org/) is a library of thousands of
books that have entered the public domain. It includes classics like Sherlock
Holmes and even obscure titles. Many of these titles are available in simple
text files which is exactly what we want. From a previous project using Markov
chains I have already collected a selection of books that I will use.

I will try to use few libraries in this project but one I have found to be
really useful in manipulating files is Pathikrit Bhowmick's
[better-files](https://github.com/pathikrit/better-files) library, and will be
using it in the creation of my word list.

Let's take a look at some code that generates a word list:

```scala
object WordListGenerator {

  import better.files._

  def main(args: Array[String]): Unit = {
    // arg 1 should be a folder containing our various text files
    // arg 2 should be the output path for our word list
    if (args.length < 2) {
      throw new IllegalArgumentException("Not enough arguments")
    }

    val textFolder = File(args(0))
    val outputFile = File(args(1))

    val textFiles = textFolder
      .list(
        f => f.isRegularFile && f.extension.contains(".txt"),
        1
      )
      .toSeq

    // This pattern matches only simple 5 letter words
    val regex = """([a-z]{5})""".r

    val words = textFiles
      .flatMap { file =>
        file
          // This splits each file up into a sequence of strings
          // separated by any of the characters in the given string
          .scanner(StringSplitter.anyOf("\n\t .,\""))()(
            _.iterator
              .map(_.toLowerCase)
              .filter(regex.matches(_))
              .toSeq
          )
          .distinct
      }
      .distinct
      .sorted

    // Finally write out the word list
    outputFile.bufferedWriter()(writer =>
      words.foreach(word => writer.write(s"$word\n"))
    )
  }

}
```

This produced a list of over 4000 words from the files I used. Unfortunately,
this word list is only as good as the files it was built from and the filtering
applied to them. Unlike a human curated list, my list contains many "words"
that most people would struggle to guess; such as roman numerals, names and
esoteric words from older English. What's good about this code is that there is
nothing stopping you from adding more filters or applying it to multiple
existing wordlists to create a much larger list of words!

Many Linux distributions already come packaged with a dictionary of
[words](https://en.wikipedia.org/wiki/Words_(Unix)) that could be used in place
of the gutenberg files.

I would recommend that any word list used has some further filters applied to
it and goes through some manual process to avoid the pitfalls noted above. One
of the word games Wordle is based on actually has a stipulation that words do
not contain multiples of the same letter, this makes it a little easier than
Wordle.

## The Game

Onto the actual game.

Given a word list (wherever it has come from), we need to
first pick a random word, then keep track of the amount of user guesses and
give appropriate response to them.

A common way to model systems, including games is to use state machines. These
are simple flow diagrams representing the states a system can be in and how it
transitions between them. In the case of Wordle there are only really 3 states:

* Playing
* Win
* Lose

With Win and Lose being terminal states.

<img
  alt='State Diagram'
  src='{{ "assets/wordle/states.png" | absolute_url  }}'
  class='blog-image'
/>

In Scala we can define these states using the type system, which allows us to
make use of Scala's pattern matching:

```scala
sealed abstract class State
case object Playing extends State
case object Win extends State
case object Lose extends State
```

Getting a random word from our file is easy enough in all programming
languages, we'd simply load each line into some kind of indexed array, generate
a random number between 0 and the array size, and access the corresponding
index in the array. Of course, when dealing with potentially large amounts of
data and only caring about a tiny amount of it we should be more conscientious
about our resource usage. In out case we can do this by counting the amount of
lines in the file, discarding them as we do, then reading through the file
again to a random number of lines within our discovered length.

```scala
def randomWord(file: File): String = {
  val lineCount = file.lineCount.toInt
  val randomNum = Random.nextInt(lineCount)
  file.lineIterator.toSeq(randomNum)
}
```

Computationally this takes longer as we read the file fully once then partially
again. But memory-wise it does not attempt to put the full contents of the file
in memory.

With a word selected we need to be able to represent it and whether a player's
guess matches it or not. In Scala we can use a case class for this to
encapsulate logic with the word itself.

```scala
sealed abstract class LetterGuess
case object Correct extends LetterGuess
case object Incorrect extends LetterGuess
case object Present extends LetterGuess

case class Word(
    letters: Seq[Char]
) {
  def word: String = letters.mkString

  def matches(guess: String): Seq[(Char, LetterGuess)] = {
    guess.zipWithIndex.map { case (c, i) =>
      val result: LetterGuess = if (letters(i) == c) {
        Correct
      } else if (letters.contains(c)) {
        Present
      } else {
        Incorrect
      }
      (c, result)
    }
  }

}

object Word {
  def apply(word: String): Word = {
    Word(word.toCharArray)
  }
}
```

The `matches` function here returns a sequence of tuples with the guessed
character and degree of correctness to it.

Brining everything together, we need a way of representing the current overall
state of the game, including the amount of guesses, the state the game is in
and the current word:

```scala
case class GameState(
    word: Word,
    guesses: Int,
    maxGuesses: Int,
    state: State
)

object GameState {
  def apply(word: String, maxGuesses: Int = 6): GameState =
    GameState(Word(word), 0, maxGuesses, Playing)
}
```

With all these states it becomes pretty simple to encode the logic of Wordle
into a recursive function:

```scala
def main(args: Array[String]): Unit = {
  if (args.length < 1) {
    println("arg 1: should be word list file")
    return
  }

  val wordList = File(args(0))
  val gameState = GameState(randomWord(wordList))

  playGame(gameState)
}

@tailrec
def playGame(game: Wordle.GameState): Unit = {
  game.state match {
    case Win | Lose =>
      println("Game Over")
      println(s"Word was: ${game.word.word}")
    case Playing =>
      println(s"You have ${game.maxGuesses - game.guesses} guesses left")
      val guess = Option(scala.io.StdIn.readLine())
      guess match {
        case None =>
          println("Exiting")
        case Some(guess) =>
          val newState = if (!guess.matches("""[a-z]{5}""")) {
            println("Guess must be 5 letters long")
            game
          } else {
            val guessCount = game.guesses + 1
            val check = game.word.matches(guess)

            // print out the status
            val status = check
              .map { case (c, guess) =>
                guess match {
                  case Correct   => s"[$c]"
                  case Incorrect => s"X${c}X"
                  case Present   => s"~${c}~"
                }
              }
              .mkString(" ")
            println(status)

            if (
              check.count { case (_, guess) =>
                guess == Correct
              } == check.length
            ) {
              println("You win!")
              game.copy(guesses = guessCount, state = Win)
            } else if (guessCount >= game.maxGuesses) {
              println("You lose!")
              game.copy(guesses = guessCount, state = Lose)
            } else {
              game.copy(guesses = guessCount)
            }
          }
          playGame(newState)
      }
  }
}
```

Here I've opted to surround correct letters like so `[a]`, incorrect letters
like `XbX`, and present but in the wrong places as `~c~`. I've used a tail
recursive function here as it helped simplify the logic somewhat. A new updated
`GameState` object is passed to the recursively called function, with the exit
condition being when the state has transitioned into either `Win` or `Lose`.

Your typical game goes something like this:

```text
You have 6 guesses left
clamp
XcX XlX [a] XmX XpX
You have 5 guesses left
hoard
XhX XoX [a] ~r~ XdX
You have 4 guesses left
bravo
XbX [r] [a] XvX XoX
You have 3 guesses left
tranq
~t~ [r] [a] XnX XqX
You have 2 guesses left
orate
XoX [r] [a] [t] [e]
You have 1 guesses left
crate
XcX [r] [a] [t] [e]
You lose!
Game Over
Word was: frate
```

While not as pretty as the real Wordle, it is just as playable and in total
fits into less than 130 lines of code (including all spaces).

