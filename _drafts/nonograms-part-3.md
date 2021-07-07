---
layout: post
title: Nonograms Part 3
tags:
- nonogram
- puzzles
- programming
- scala
---

In my last 2 posts I was working on a way to processes Nonograms in Scala. In
the [first]({% post_url 2021-07-03-nonograms %}) I outlined what they were and
a file format to store them in.
In the [second]({% post_url 2021-07-05-nonograms-part-2 %}) I showed my code in
Scala to represent them and parse them from the file format I defined.
In this post I will continue on with code to write out the file format and
render them.

To start with I decided to go back and refactor some of my code so it aligned
with my file format. This meant adding the title, author and solution to the
Nonogram class. I also altered the pretty printing of the Nonogram so it was
easier for me to reason about during testing:

```scala
final case class Nonogram(
    grid: Grid,
    horizontalHints: Hints,
    verticalHints: Hints,
    title: String = "",
    author: String = "",
    solution: Option[Grid] = None
) {

  val width: Int  = grid.width
  val height: Int = grid.height

  def pretty(): String = {
    val horizontalString = horizontalHints.pretty()
    val verticalString   = verticalHints.pretty()
    val gridString       = grid.pretty()
    val solutionString   = solution.map(_.pretty()).getOrElse("")

    val sb = new StringBuilder(
      title.length +
        author.length +
        horizontalString.length +
        verticalString.length +
        gridString.length +
        solutionString.length +
        100
    )

    sb.append("title:")
    if(title.nonEmpty) sb.append(title)
    sb.append("\n\n")

    sb.append("author:")
    if(title.nonEmpty) sb.append(author)
    sb.append("\n\n")

    sb.append("column hints:\n")
    sb.append(horizontalString)
    sb.append("\n\n")

    sb.append("row hints:\n")
    sb.append(verticalString)
    sb.append("\n\n")

    sb.append("grid:\n")
    sb.append(gridString)
    sb.append("\n")

    sb.append("solution:\n")
    sb.append(solutionString)

    sb.toString()
  }

  override def toString: String = pretty()
}
```

This obviously meant I also had to refactor my tests, I won't show how here in
order to keep the blog post shorter but I will say I ended up adding a solution
test as well as externalising the expected text result into a file.

Along with the Nonogram class itself I improved the NonogramBuilder class. The
changes were to add the fields to the built Nonogram.

With both these changes done I quickly made my SimpleNonogramReader class able
to pass the extra fields to the builder and fixed a bug within it with the last
sections not being added to the builder.

So onto the Nonogram writer! My first step was again defining a trait:

```scala
import java.io.{File, FileOutputStream, OutputStream}
import java.nio.file.Path
import scala.util.{Try, Using}

trait NonogramWriter {

  def write(nonogram: Nonogram, path: Path): Try[Unit] =
    write(nonogram, path.toFile)

  def write(nonogram: Nonogram, file: File): Try[Unit] =
    Using(new FileOutputStream(file)) {
      write(nonogram, _)
    }

  def write(nonogram: Nonogram, outputStream: OutputStream): Try[Unit]
}
```

I made use of the `Try` structure in Scala here to encapsulate any errors that
occur during writing instead of throwing them. This also meant I could define
the 3 different overloaded functions for writing and have 2 defer to a simple
output stream based method.

Now the SimpleNonogramWriter implementation is much much simpler than the
reader. All it has to do is output the existing Nonogram in the defined format.
For this I made use of a Writer class from the standard Java library:

```scala
import java.io.{BufferedWriter, OutputStream, OutputStreamWriter}
import java.nio.charset.StandardCharsets
import scala.util.Try

object SimpleNonogramWriter extends NonogramWriter {

  override def write(
      nonogram: Nonogram,
      outputStream: OutputStream
  ): Try[Unit] =
    Try {
      val writer = new BufferedWriter(
        new OutputStreamWriter(outputStream, StandardCharsets.UTF_8)
      )

      writer.write(s"${nonogram.width}x${nonogram.height}\n")
      writer.write("\n")

      writer.write("title\n")
      writer.write(nonogram.title)
      writer.write("\n\n")

      writer.write("author\n")
      writer.write(nonogram.author)
      writer.write("\n\n")

      writer.write("rows\n")
      nonogram.verticalHints.hints
        .map { hint =>
          s"${hint.mkString(",")}\n"
        }
        .foreach(writer.write)
      writer.write("\n")

      writer.write("columns\n")
      nonogram.horizontalHints.hints
        .map { hint =>
          s"${hint.mkString(",")}\n"
        }
        .foreach(writer.write)
      writer.write("\n")

      writer.write("grid\n")
      writer.write(writeGrid(nonogram.grid))

      nonogram.solution.foreach { solution =>
        writer.write("\nsolution\n")
        writer.write(writeGrid(solution))
      }

      writer.flush()
    }

  private def writeGrid(grid: Grid): String = grid.pretty()
}
```

You'll note the `flush` at the end. I did this since the writer, and underlying
stream, are not closed by this method so I needed to reliably flush the output
to the stream. I could have done multiple flushes, perhaps one after each
section but that is mostly unnecessary; even when dealing with large Nonograms
the BufferedWriter will handle flushing its buffer sensibly.

In order to test the writer I wrote a simple test:

```scala
import java.io.FileOutputStream
import java.nio.file.Files

class SimpleNonogramWriterTest extends AnyFunSuite {

  test("example works") {

    val example = Nonogram(
      NonogramTestExamples.exampleGrid,
      NonogramTestExamples.exampleHorzHints,
      NonogramTestExamples.exampleVertHints,
      "test title",
      "test",
      Some(NonogramTestExamples.exampleSolution)
    )

    val temp   = Files.createTempFile("nonogram", ".non").toFile
    temp.deleteOnExit()

    val output = new FileOutputStream(temp, true)
    val wrote = SimpleNonogramWriter.write(example, output)
    assert(wrote.isSuccess, "Failed to write")

  }

}
```

This test does not do much right now other than ensure writing succeeds so I
needed to extend the tests to make sure the output is as expected:

```scala
import java.io.{File, FileOutputStream}
import java.nio.charset.StandardCharsets
import java.nio.file.Files

class SimpleNonogramWriterTest extends AnyFunSuite {

  private val exampleNonogram = Nonogram(
    NonogramTestExamples.exampleGrid,
    NonogramTestExamples.exampleHorzHints,
    NonogramTestExamples.exampleVertHints,
    "test title",
    "test",
    Some(NonogramTestExamples.exampleSolution)
  )

  private val exampleExpectedOutput: String =
    Files.readString(
      new File(getClass.getResource("/expected.non").toURI).toPath,
      StandardCharsets.UTF_8
    )


  test("can write") {
    val temp   = Files.createTempFile("nonogram", ".non").toFile
    temp.deleteOnExit()

    val output = new FileOutputStream(temp, true)
    val wrote = SimpleNonogramWriter.write(exampleNonogram, output)
    assert(wrote.isSuccess, "Failed to write")
  }

  test("example works") {

    val example = Nonogram(
      NonogramTestExamples.exampleGrid,
      NonogramTestExamples.exampleHorzHints,
      NonogramTestExamples.exampleVertHints,
      "test title",
      "test",
      Some(NonogramTestExamples.exampleSolution)
    )

    val temp   = Files.createTempFile("nonogram", ".non").toFile
    temp.deleteOnExit()

    val output = new FileOutputStream(temp, true)
    val wrote = SimpleNonogramWriter.write(example, output)
    assert(wrote.isSuccess, "Failed to write")

    val outputString = Files.readString(temp.toPath)

    assert(outputString == exampleExpectedOutput, "Output does not match input")

  }

}
```

You'll note there are 2 tests here. The first just tests if we can write out a
Nonogram whereas the second tests that the output is as expected. Keeping these
separate allows me to detect if there is an issue in writing or an issue in the
output itself. I could add further tests for corner cases but this will do for
now.

I stored the expected output in a file called `expected.non` and it looks like
the following:

```txt
8x11

title
test title

author
test

rows
0
4
6
2,2
2,2
6
4
2
2
2
0

columns
0
9
9
2,2
2,2
4
4
0

grid
X X X X X X X X
. # . . . . . .
. # . # # . . .
. . . . . . . .
X . . . X . . .
. . . . . . . X
. . . . . . . .
. . . X X . . .
. . . . . . . X
. . # . . . . .
X X . . . X . .

solution
. . . . . . . .
. # # # # . . .
. # # # # # # .
. # # . . # # .
. # # . . # # .
. # # # # # # .
. # # # # . . .
. # # . . . . .
. # # . . . . .
. # # . . . . .
. . . . . . . .

```

And the tests pass! So now we can read and write Nonograms in Scala! Let's move
onto a simple rendering of them as an image. Since I created the NonogramWriter
trait I can reuse it here for writing out a simple image:

```scala
```
