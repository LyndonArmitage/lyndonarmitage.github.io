---
layout: post
title: Scala Word Wheel Solver
tags: [medium, blog, scala]
---

<p class="message">
This post was originally published on my old blog and
<a href="https://medium.com/@lyndon.armitage/scala-word-wheel-solver-460744d7b9ab">
Medium</a>. It was written when I was relatively new to the Scala programming
language.
</p>

A few years ago I created a
[Word Wheel solver in Java and Android](https://web.archive.org/web/20160323053418/lyndonarmitage.com/word-wheel-solverhelper/),
earlier this year (January) I again decided to create a Word wheel solver but
this time in Scala. I tweeted out the result, a program less than 100 lines
long, a lot shorter compared to my Java version (it also runs a lot faster) but
I thought I’d revisit it in a blog post.

## Scala

First and foremost for those unfamiliar with it; Scala is a functional
programming language that runs on the Java Virtual Machine.  
It is incredibly feature rich and allows you to solve some problems much more
elegantly than more Object Orientated languages like Java or C++.

Like Python; Scala features a powerful interpreter that allows you to evaluate
code on the fly:

```scala
Welcome to Scala 2.11.8 (OpenJDK 64-Bit Server VM, Java 1.8.0_92).
Type in expressions for evaluation. Or try :help.

scala> 1 + 1
res0: Int = 2

scala>
```

Which can prove invaluable when testing or exploring data.

For those interested in Scala I highly recommend the
[Scala language website](http://www.scala-lang.org/) and for those who are
familiar with Java, the
[Scala for Java Programmers book](https://www.amazon.co.uk/Learn-Scala-Java-Developers-Weston/dp/1508734178/ref=sr_1_1?ie=UTF8&qid=1469726665&sr=8-1&keywords=scala+for+java).

## Word Wheel

A Word Wheel is a simple puzzle where you try to create as many words as you
can from a set of letters, with one (or more) letters having to be in all your
words.

<img alt='This is an example Word Wheel with the required letter of D and optional letters of N,G,A,R,S,E,O, and U' title='This is an example Word Wheel with the required letter of D and optional letters of N,G,A,R,S,E,O, and U' src='{{ "assets/medium/wordwheel/wheel.jpg" | absolute_url }}' class='blog-image' >

Normally there is also a word that uses all the letters in the Word Wheel, can
you see what it is in the given example?

## Word Wheel Solver

Now that is out-of-the-way onto my Word Wheel Solver.

The Word Wheel solver has 3 required arguments:

1. Required Letter — The letter required to be within any made words
2. Optional Letters — The letters surrounding the required letter
3. Path to a word list — A file with a word per line

And a 4th optional argument; the minimum length words can be, by default this
is set to 3.

The first 2 arguments are straight forward when you look at Word Wheel, however
for the word list you can use the
[Unix words file](https://en.wikipedia.org/wiki/Words_(Unix)), generate your
own from text, or download an existing words list.

## Generating a Word List

I normally download an existing word list but generating a word list is
relatively easy so I will show how to do that using text files (books) provided
by [Project Gutenberg](https://www.gutenberg.org/).

For this example I have chosen the following books:

* Pride and Prejudice
* A Tale of Two Cities
* The Adventures of Sherlock Holmes
* The Adventures of Huckleberry Finn
* The Picture of Dorian Gray

I downloaded the UTF-8 text versions of these files and placed them in a
folder.

To turn these books into a list of words I wrote the following Scala program
(explanation of what it does is below):

```scala
import java.io.{BufferedWriter, File, FileWriter}

import scala.collection.mutable

object WordListGenerator {

  def main(args: Array[String]): Unit = {
    assert(args.length > 0)
    val words = new mutable.HashSet[String]
    args.map(arg =>
      scala.io.Source.fromFile(arg, "UTF-8")
    )
      .map(source => source.getLines())
      .foreach(it => {
        it.filterNot(line => line.isEmpty)
          .map(line => sanitizeLine(line))
          .filterNot(line => line.isEmpty)
          .map(line > getWords(line))
          .foreach(set => words ++= set)
      })

    println("Outputting word list")
    val outputFile = new File("wordlist.txt")
    val writer = new BufferedWriter(new FileWriter(outputFile))
    words.foreach(word => {
      writer.write(word)
      writer.newLine()
    })
    writer.close()
    println("Finished writing word list")
  }

  def sanitizeLine(line: String): String = {
    var newLine = line.toLowerCase.trim
    val specialCharRanges = Range.inclusive(33, 47) ++ Range.inclusive(58, 64) ++ Range.inclusive(91, 96) ++ Range.inclusive(123, 126)
    specialCharRanges.map(i => i.toChar)
      .foreach(charValue => {
        newLine = newLine.replace(charValue, ' ')
      })
    newLine
  }

  def getWords(line: String): Set[String] = {
    val seperators = Array(' ', '\t')
    line.split(seperators)
      .map(word => word.trim)
      .filterNot(word => word.isEmpty)
      .toSet
  }
}
```

1. This program takes a 1 or more paths to text files as arguments.
2. It creates a mutable set to store all words in
3. Then it iterates over each file and opens them
4. For each line in the file it sanitizes the input: making sure to replace all
   special characters with a space, and makes everything lower case
5. Then for each of these lines it splits the line on spaces and tabs and
   creates a set of the resulting words
6. This words set is then added to the main words set
7. Then it opens a file called wordlist.txt and populates it with all the words
   in the word set

This produces me a file with almost 20,000 ‘words’. Some of these aren’t really
words but I have ignored those for now.

## The Solver Code

Now I have a word list I can run my Word Wheel solver on the example Word Wheel
given above using the it.

Below is the source to the Word Wheel solver:

```scala
import scala.collection.mutable

object WordWheelSolver {

  private val defaultMinSize = 3

  def main(args: Array[String]) {
    if (args.length >= 3) {
      val minLetters: Int = {
        if (args.length >= 4) {
          args(3).toInt
        } else {
          defaultMinSize
        }
      }
      val required: Char = args(0).charAt(0)
      if (args(0).length > 1) {
        Console.err.println("Using first character of arg1 (" + required + ") only")
      }
      val others = args(1).toList
      val wordList = loadWordList(args(2), minLetters)
      val results = solve(required, others, wordList, minLetters)
      results.foreach(println)
    } else {
      Console.err.println("Requires 3 arguments:")
      Console.err.println("arg 1: Required letters")
      Console.err.println("arg 2: Optional letters")
      Console.err.println("arg 3: Path to word list")
      Console.err.println("arg 4 (Optional): Min letter count, defaults to " + defaultMinSize)
    }
  }

  def loadWordList(path: String, minLength: Int): Iterator[String] = {
    scala.io.Source.fromFile(path, "UTF-8")
      .getLines()
      .filter(_.length >= minLength)
  }

  def createWordMap(wordList: Iterator[String]): Map[String, List[String]] = {
    val toWords: mutable.HashMap[String, List[String]] = mutable.HashMap[String, List[String]]()
    // Take each word and map it to it's ordered counterpart
    wordList.foreach(word => {
      val ordered = sortWord(word)
      if (toWords.contains(ordered)) {
        toWords.put(ordered, toWords.get(ordered).get :+ word)
      } else {
        toWords.put(ordered, List[String](word))
      }
    })
    // convert to an immutable map
    toWords.toMap
  }

  def sortWord(word: String) = word.toCharArray.sorted.mkString

  def solve(required: Char, otherChars: List[Char], wordList: Iterator[String], minLength: Int): Seq[String] = {

    // Define a hash map for storing ordered word strings to the original words
    val toWords = createWordMap(wordList)

    // Generate all possible combinations of otherChars + the required character
    val allPossibles = Range.inclusive(minLength - 1, otherChars.length)
      .flatMap(i => otherChars.combinations(i))
      .sortWith((left, right) => left.length > right.length)
      .map(l => l.::(required))
      .map(s => sortWord(s.mkString))
      .iterator

    // Get a flat list of the results
    allPossibles.flatMap(possible => {
      toWords.get(possible)
    }).flatten.toSeq
  }

}
```

The bulk of the work is done within the `solve` and `createWordMap` methods.

### `createWordMap` Method

This method takes the words from the word list and creates a map of letters to
corresponding words. For example:

Imagine our word list consisted of the 2 words: __cat__ and __act__.  
This method would:

1. Takes the word __cat__
2. Orders the letters alphabetically (act)
3. Finds the entry in the map for those letters (act), if it fails to find the
   entry it create a new one mapping the letters (act) to a list of words
   containing the word __cat__
4. Next it takes the word __act__
5. Order the letters alphabetically (act)
6. Finds the entry in the map for those letters (act) and adds the word __act__
   to the list already present

This data structure allows you to find anagrams of words which will prove
useful in the main solve method.

### `solve` Method

The next line after creating the word map in the solve method does the bulk of
the computation in the solve method.  
It basically generates all possible combinations of the optional letters and
required letter.

The last bit of code in this method than uses the map generated earlier and
attempts to match up the generated combinations with the its entries.  
Any matches are flattened down to a sequence that is then printed to the
console in the main method.

## The Results

When run against the example Word Wheel using the generated word list I get the
following results:

```text
dangerous
dangers
gardens
groaned
aground
grounds
undergo
asunder
resound
aroused
ranged
garden
gander
grande
danger
dragon
ground
snared
around
rondes
snored
nursed
rounds
guards
argued
gourds
adores
soared
roused
soured
grand
daren
arden
doran
adorn
under
round
nosed
doesn
ondes
sound
drags
guard
dregs
drugs
urged
gourd
reads
dares
roads
adore
doers
dang
dasn
sand
dane
doan
dern
rend
ends
dens
send
nods
done
undo
drag
egad
aged
drug
dogs
gods
doge
ards
dear
read
dare
road
soda
rods
rode
rude
does
dose
used
sued
dues
and
dan
den
ned
end
nod
don
dun
und
god
dog
dug
dar
sad
ado
red
rod
des
ode
due
```

Some of these don’t look like real words; this is because the contents of the
words list I generated contains some misspellings, slang words and badly
formatted text.

It does however contain the long word using all the letters: “dangerous” along
with many other real words that can be found in the word wheel.

And that concludes this post, feel free to leave any comments on the code
provided here.
