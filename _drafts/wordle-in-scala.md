---
layout: post
title: 'Wordle in Scala: The Word List'
tags:
- game
- wordle
- scala
- code
- programming
- puzzles
---

The game [Wordle](https://www.nytimes.com/games/wordle/index.html) seems to
have come out of nowhere recently and become a favourite among so many. In this
post I will begin to show how you can make a game similar to Wordle and the
games it is based upon.

First off a quick assessment of what Wordle is:  
Worlde is a puzzle game where you are tasked with guessing a 5 letter word in 6
guesses. Each time you guess, you are told which letters you got in the right
place, which ones are present but not in the right place and which letters are
not present. If after 6 guesses you don't guess the word then you lose and must
wait for the next word to be generated.

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

Let's take a look at the code to generate a word list:

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
    val regex = """([A-Z]{5})""".r

    val words = textFiles
      .flatMap { file =>
        file
          // This splits each file up into a sequence of strings separated by
          // any of the characters in the given string
          .scanner(StringSplitter.anyOf("\n\t .,\""))()(
            _.iterator
              .map(_.toUpperCase)
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

This produced me a list of over 4000 words. Unfortunately, this word list is
only as good as the files it was built from and the filtering applied to them.
Unlike a human curated list, it contains many "words" that most people would
struggle to guess such as roman numerals, names and esoteric words from older
English. What's good about this code is that there is nothing stopping you from
adding more filters or applying it to multiple existing wordlists to create a
much larger list of words!

In my next post I will show how to take this word list and use it in the
creation of the core Wordle-like program.
