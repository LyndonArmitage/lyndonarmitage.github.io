---
layout: post
title: Nonograms Part 2
tags:
- nonogram
- puzzles
- programming
- bnf
- scala
---

In my [previous post]({% post_url 2021-07-03-nonograms %}) I described what a
Nonogram was and crafted a file format to use for representing a Nonogram and
any clues/hints associated with it. In this post I intend to go through the
steps of building software to read, write and display Nonograms in the decided
format.

For this project I have opted to use Scala. As much as I enjoy writing in C I
desired a higher level programming language with my constructs I can take
advantage of, including some level of object orientation and Scala fits the
bill.

My first business is to decide how to represent a Nonogram in code. When
approaching any software development I try to keep my code close to the domain
in question by using the facilities of the language. To this end I opted to
make use of Scala's case classes and object orientation to craft a model of a
Nonogram.

First I created the top-level Nonogram class. I identified that all it needed
the grid and horizontal and vertical hints.

```scala
final case class Nonogram(
    grid: Grid,
    horizontalHints: Hints,
    verticalHints: Hints
)
```

The hints were easy to model in Scala, essentially being a sequence of numbers.
I opted to again use a case class to wrap around a simple sequence of integers.

```scala
object Hints {
  type Hint = Seq[Int]

}

final case class Hints(
    hints: Seq[Hint]
) {

  def pretty(): String = hints.map(hint => hint.mkString(",")).mkString("\n")

  override def productElement(n: Int): Hint = hints(n)

  override def productIterator: Iterator[Hint] = hints.iterator

  override def toString: String = pretty()
}
```

This wrapping may seem like overkill but when trying to maintain a Domain
Driven Design it can greatly help as it maintains the concept of what you are
modelling via encapsulation.

For the grid I again opted to encapsulate it within a case class:

```scala
object Grid {
  type GridRow = Seq[Square]

  def empty(width: Int, height: Int) : Grid = {
    val row: Seq[Square] = Seq.fill[Square](width)(Blank)
    val rows: Seq[GridRow] = Seq.fill[GridRow](height)(row)
    Grid(rows)
  }
}

final case class Grid(
    rows: Seq[GridRow]
) {
  val width: Int  = rows.map(_.length).max
  val height: Int = rows.length
}
```

Here I included a helper method on the companion object to create an empty
instance of a Grid.

Finally for the grid squares I opted to represent them using the following
pattern:

```scala
sealed abstract class Square(
    val char: Char
) {
  def pretty(): String = s"$char"

  override def toString: String = pretty()
}

case object Blank    extends Square('.')
case object Occupied extends Square('#')
case object Crossed  extends Square('X')
```

This style approximates an enumerated type in Scala and allows for pattern
matching that may come in handy if I want to create a Nonogram solver.

Stepping back to the Nonogram class now that I had implemented all of it's
constituent parts I opted to add a pretty printing option to it for easier
debugging.

```scala
def pretty(): String = {
  val horizontalString = horizontalHints.pretty()
  val verticalString = verticalHints.pretty()
  val gridString = grid.pretty()
  s"column hints:\t$horizontalString\nrow hints:\t$verticalString\ngrid:\n$gridString"
}
```

This involved adding a pretty printing option to the Grid class:

```scala
def pretty(): String = {
  val sb = new StringBuilder((width * 3) * (height * 2))
  0.until(height).map { y =>
    val row: GridRow = rows.lift(y).getOrElse(Grid.emptyGridRow(width))
    0.until(width).map { x =>
      val square: Square = row.lift(x).getOrElse(Blank)
      sb.append(square.pretty())
      if (x < width - 1) sb.append(" ")
    }
    sb.append("\n")
  }

  sb.toString()
}
```

Now in theory I would be able to see my Nonograms printed to the console. So I
added some very simple tests to make sure this was the case.

In creating my tests I ended up having to perform some refactoring. I altered
signatures to use Scala's var-args support instead of passing sequences
everywhere:

```scala
final case class Grid(
    rows: GridRow*
) {
  // ...
}
// ...
final case class Hints(
    hints: Hint*
) {
  // ...
}
```

Refactored the Grid companion object to provide some more helper methods:

```scala
object Grid {
  type GridRow = Seq[Square]

  def emptyGridRow(width: Int): GridRow = Seq.fill[Square](width)(Blank)

  def rowFromString(string: String): GridRow = {
    if (string.isEmpty)
      throw new IllegalArgumentException("string cannot be empty")
    string.map { c =>
      val x = Square.fromChar(c)
      x match {
        case Some(value) => value
        case None =>
          throw new IllegalArgumentException(s"$c is not a valid grid value")
      }
    }
  }

  def empty(width: Int, height: Int): Grid = {
    val row  = emptyGridRow(width)
    val rows = Seq.fill[GridRow](height)(row)
    Grid(rows:_*)
  }

}
```

And added a companion object for my enumerated type:

```scala
object Square {
  val types: Seq[Square] = Seq(Blank, Occupied, Crossed)
  val charToTypes: Map[Char, Square] = types.map(t => (t.char, t)).toMap

  def fromChar(char: Char): Option[Square] = charToTypes.get(char)
}
```

This all allowed me to write this very simple ScalaTest:

```scala
class NonogramTest extends AnyFunSuite {

  private val exampleGrid: Grid = Grid(
    Grid.emptyGridRow(8),
    Grid.rowFromString(".####..."),
    Grid.rowFromString(".######."),
    Grid.rowFromString(".##..##."),
    Grid.rowFromString(".##..##."),
    Grid.rowFromString(".######."),
    Grid.rowFromString(".####..."),
    Grid.rowFromString(".##....."),
    Grid.rowFromString(".##....."),
    Grid.rowFromString(".##....."),
    Grid.emptyGridRow(8)
  )

  private val exampleHorzHints: Hints = Hints(
    Seq(0),
    Seq(9),
    Seq(9),
    Seq(2, 2),
    Seq(2, 2),
    Seq(4),
    Seq(4),
    Seq(0)
  )

  private val exampleVertHints: Hints = Hints(
    Seq(0),
    Seq(4),
    Seq(6),
    Seq(2, 2),
    Seq(2, 2),
    Seq(6),
    Seq(4),
    Seq(2),
    Seq(2),
    Seq(2),
    Seq(0)
  )

  test("pretty printing works as expected") {
    val nonogram = Nonogram(exampleGrid, exampleHorzHints, exampleVertHints)

    val printed = nonogram.pretty()
    val expected =
      """|column hints:
        |0
        |9
        |9
        |2,2
        |2,2
        |4
        |4
        |0
        |row hints:
        |0
        |4
        |6
        |2,2
        |2,2
        |6
        |4
        |2
        |2
        |2
        |0
        |grid:
        |. . . . . . . .
        |. # # # # . . .
        |. # # # # # # .
        |. # # . . # # .
        |. # # . . # # .
        |. # # # # # # .
        |. # # # # . . .
        |. # # . . . . .
        |. # # . . . . .
        |. # # . . . . .
        |. . . . . . . .
""".stripMargin
    assert(printed == expected)
  }

}
```

This debug output is already very close to the format I mentioned in my
previous post! Since that is the case my next step may as well be adding the
ability to write the format in question!

Since in my previous post I noted there are a variety of preexisting formats
for Nonograms I opted to separate this functionality out into a trait and it's
implementors.

```scala
import java.nio.file.Path

trait NonogramReader {

  def apply(file: Path): Nonogram = parse(file)
  
  def parse(file: Path): Nonogram
}
```

This way I can implement a reader for other file types if I want to without
having to do any massive refactoring of my code.
