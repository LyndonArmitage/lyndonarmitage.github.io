---
layout: post
title: Nonograms Part 2
tags:
- nonogram
- puzzles
- programming
- bnf
- scala
date: 2021-07-05 18:49 +0100
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
import java.io.{FileInputStream, InputStream}
import java.nio.file.Path
import scala.util.{Try, Using}

trait NonogramReader {

  def apply(file: Path): Try[Nonogram] = parse(file)

  def parse(file: Path): Try[Nonogram] =
    Using(new FileInputStream(file.toFile)) { is =>
      parse(is)
    }

  def parse(inputStream: InputStream): Nonogram
}

```

This way I can implement a reader for other file types if I want to without
having to do any massive refactoring of my code.

Now actually parsing the file format is quite involved so I will present the
whole code first then explain parts of it.

```scala
package codes.lyndon.nonogram.reader
import codes.lyndon.nonogram.Grid.GridRow
import codes.lyndon.nonogram.{Hints, Nonogram, NonogramBuilder, Square}
import org.slf4j.LoggerFactory

import java.io.InputStream
import scala.collection.mutable
import scala.collection.mutable.ListBuffer

case class NotAValidNonogram(message: String, cause: Throwable = null)
    extends Exception(message, cause)

object SimpleNonogramReader extends NonogramReader {

  private val logger = LoggerFactory.getLogger(getClass)

  private val validGridChars: Set[Char] = Square.charToTypes.keySet ++ Set(' ')

  def parse(inputStream: InputStream): Nonogram = {

    val allLines =
      scala.io.Source.fromInputStream(inputStream).getLines().toIndexedSeq

    // First line must be the dimensions of the Nonogram in the form:
    // [width]x[height]
    val firstLine = allLines.headOption match {
      case Some(value) => value
      case None        => throw NotAValidNonogram("File is empty")
    }

    val (width, height) = parseDimensions(firstLine) match {
      case Some(value) => value
      case None =>
        throw NotAValidNonogram(
          "Dimensions should be the first line in the format [width]x[height]"
        )
    }

    if (width <= 0) throw NotAValidNonogram("width must be greater than 0")
    if (height <= 0) throw NotAValidNonogram("height must be greater than 0")

    // Second line should be blank
    val secondLine = allLines.drop(1).headOption match {
      case Some(value) => value
      case None        => throw NotAValidNonogram("Missing all sections")
    }

    if (!secondLine.isBlank) {
      throw NotAValidNonogram("Second line must be blank")
    }

    logger.debug(s"Nonogram has dimensions of: $width x $height")

    // Now comes the true complexity, parsing the rest of the format
    parseSections(width, height, allLines.drop(2))
  }

  private def parseSections(
      width: Int,
      height: Int,
      lines: IndexedSeq[String]
  ): Nonogram = {
    val sectionBuilder = new SectionBuilder(width, height)
    var lineNum        = 0
    while (lineNum < lines.length) {
      val line = lines(lineNum)
      if (line.isBlank) {
        if (sectionBuilder.hasSection) {
          sectionBuilder.buildSection()
          sectionBuilder.clearSection()
        }
      } else {
        if (sectionBuilder.hasSection) {
          sectionBuilder.parseLine(line)
        } else {
          sectionBuilder.section = getSectionHeader(line)
          if (!sectionBuilder.hasSection) {
            throw NotAValidNonogram(s"$line is not a valid section")
          }
        }
      }
      lineNum = lineNum + 1
    }

    sectionBuilder.build()
  }

  private class SectionBuilder(width: Int, height: Int) {
    var section: Option[Section]          = None
    val lines: mutable.ListBuffer[String] = ListBuffer.empty

    private val builder = NonogramBuilder(width, height)

    def hasSection: Boolean = section.isDefined

    def parseLine(line: String): Unit = {
      section.foreach { sec =>
        if (sec.validateLine(line)) {
          lines.addOne(line)
        } else {
          throw NotAValidNonogram(s"$line is not a valid line for $sec")
        }
      }
    }

    def buildSection(): Unit = {
      if (!hasSection) {
        return
      }
      section.foreach {
        case Title =>
          builder.setTitle(lines.head)
        case Author =>
          builder.setAuthor(lines.head)
        case Rows =>
          val hints = lines.map { line =>
            line.split(',').map(_.toInt).toSeq
          }
          builder.setVerticalHints(Hints(hints.toSeq: _*))
        case Columns =>
          val hints = lines.map { line =>
            line.split(',').map(_.toInt).toSeq
          }
          builder.setHorizontalHints(Hints(hints.toSeq: _*))
        case Grid =>
          val rows: Seq[GridRow] = lines.map { line =>
            line
              .split(' ')
              .map { token =>
                if (token.length != 1) {
                  throw NotAValidNonogram(s"$token is not a valid grid token")
                }
                token.head
              }
              .map(Square.fromChar)
              .map {
                case Some(value) => value
                case c @ None =>
                  throw NotAValidNonogram(s"$c is not a valud grid token")
              }
              .toSeq
          }.toSeq
          val grid = codes.lyndon.nonogram.Grid(rows: _*)
          builder.setGrid(grid)
        case Solution =>
          logger.debug("Solution not implemented yet")
      }

    }

    def build(): Nonogram = {
      builder.build()
    }

    def clearSection(): Unit = {
      section = None
      lines.clear()
    }
  }

  private def getSectionHeader(line: String): Option[Section] =
    Section.headerMap.get(line)

  private def isValidGridLine(line: String): Boolean =
    line.forall(validGridChars.contains)

  private def isValidHintLine(line: String): Boolean =
    line.forall(c => c.isDigit || c == ' ' || c == ',')

  private def parseDimensions(line: String): Option[(Int, Int)] = {
    if (line.isBlank) return None
    val split = line.split('x')
    if (split.length != 2) return None
    val arr = split
      .map(_.toIntOption match {
        case Some(value) => value
        case None        => return None
      })
    Some(arr(0), arr(1))
  }

  object Section {
    val types: Set[Section]             = Set(Title, Author, Rows, Columns, Grid, Solution)
    val headerMap: Map[String, Section] = types.map(t => (t.text, t)).toMap
  }

  sealed abstract class Section(val text: String) {
    def validateLine(line: String): Boolean
    override def toString: String = text
  }

  case object Title extends Section("title") {
    override def validateLine(line: String): Boolean = true
  }
  case object Author extends Section("author") {
    override def validateLine(line: String): Boolean = true
  }
  case object Rows extends Section("rows") {
    override def validateLine(line: String): Boolean = isValidHintLine(line)
  }
  case object Columns extends Section("columns") {
    override def validateLine(line: String): Boolean = isValidHintLine(line)
  }
  case object Grid extends Section("grid") {
    override def validateLine(line: String): Boolean = isValidGridLine(line)
  }
  case object Solution extends Section("solution") {
    override def validateLine(line: String): Boolean = isValidGridLine(line)
  }
}
```

Along with this I created a very simple builder class:

```scala
final case class CouldNotBuildNonogram(
    message: String,
    cause: Throwable = null
) extends Exception(message, cause)

final case class NonogramBuilder(
    width: Int,
    height: Int
) {

  private var title: String  = ""
  private var author: String = ""

  private var grid: Option[Grid]             = None
  private var horizontalHints: Option[Hints] = None
  private var verticalHints: Option[Hints]   = None

  def setTitle(title: String): Unit = this.title = title

  def setAuthor(author: String): Unit = this.author = author

  def setGrid(grid: Grid): Unit = this.grid = Some(grid)

  def setHorizontalHints(hints: Hints): Unit = horizontalHints = Some(hints)

  def setVerticalHints(hints: Hints): Unit = verticalHints = Some(hints)

  def build(): Nonogram = {

    val grid = this.grid.getOrElse(Grid.empty(width, height))

    val horizontalHints = this.horizontalHints match {
      case Some(value) => value
      case None        => throw CouldNotBuildNonogram("No horizontalHints supplied")
    }

    val verticalHints = this.verticalHints match {
      case Some(value) => value
      case None        => throw CouldNotBuildNonogram("No verticalHints supplied")
    }

    Nonogram(grid, horizontalHints, verticalHints)
  }
}
```

The basic algorithm this follows is:

1. Ensure the first line is the dimensions in the form of [width]x[height]
2. Ensure the second line is blank
3. For the rest of the file go through each line searching for the first valid
   section.
4. From there ensure each following line is valid for that section until you
   encounter an empty line.
5. Attempt to build the given section then repeat steps 3 and 4 until the end
   of the file is reached.

I have made use of some pattern matching built into Scala to simplify steps 3
and 4. I also created helper builder classes for holding intermediate data
while the Nonogram is being built.

There are of course many improvements that can be made to this code including
ensuring that the grid sections match the given widths and heights as well as
the hint sections. I also do not use the solution section at present.

This has become quite a long and code heavy blog post again so I will continue
in yet [another entry]({% post_url 2021-07-07-nonograms-part-3 %}) on rendering
and writing the Nonograms.
