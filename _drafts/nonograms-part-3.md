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
trait I can reuse it here for writing out a simple image of the Nonogram.
However I noticed an issue with the NonogramWriter traits default
implementation where it would silently swallow failures that occurred in the
method we have to implement so I quickly patched it:

```scala
def write(nonogram: Nonogram, file: File): Try[Unit] =
  Using(new FileOutputStream(file)) {
    write(nonogram, _)
  }.flatten
// The flatten here ensures that the returned Try[Try[Unit]] is flattened to a
// Try[Unit] and the underlying failures aren't just thrown away
```

Now I used the Java standard libraries ImageIO classes to render my Nonograms.
The code is not particularly neat or concise and likely has some bugs in it but
it renders a simple Nonogram nicely. Before I show the code I added the
following to my Grid class for convenience:

```scala
def apply(x: Int)(y: Int) : Square = rows(y)(x)
```

This allowed me to access parts of a Grid instance like so: `grid(x)(y)` making
it easier to randomly access the entries within the grid.

Onto the long, messy, rendering code:

```scala

import codes.lyndon.nonogram._

import java.awt.image.BufferedImage
import java.awt.{Color, Font}
import java.io.OutputStream
import javax.imageio.ImageIO
import scala.util.Try

final case class CouldNotWriteImage(message: String, cause: Throwable = null)
    extends Exception(message, cause)

final case class ImageNonogramWriter(
    cellSize: Int = 15,
    fontSize: Int = 12,
    fontBorder: Int = 2,
    fontName: String = Font.MONOSPACED,
    renderSolution: Boolean = true
) extends NonogramWriter {

  private val font: Font = new Font(fontName, Font.PLAIN, fontSize)

  private val emptyColours = (
    new Color(219, 219, 219),
    new Color(255, 255, 255)
  )

  private val crossedColour = Color.DARK_GRAY
  private val filledColour  = Color.BLACK

  override def write(
      nonogram: Nonogram,
      outputStream: OutputStream
  ): Try[Unit] =
    Try {
      if (cellSize < 1)
        throw CouldNotWriteImage("cellSize must be at least 1 pixel big")

      // Split this into 2 parts:
      // Grid rendering and hint rendering
      val gridImage = renderGrid(nonogram.grid, cellSize)

      // Embed the grid images into a wider image

      val maxNumberOfHorizontalHints =
        nonogram.horizontalHints.hints.map(f => f.length).maxOption.getOrElse(0)
      val maxNumberOfVerticalHints =
        nonogram.verticalHints.hints.map(f => f.length).maxOption.getOrElse(0)

      val horizontalHintSectionSize =
        (fontSize + fontBorder) * maxNumberOfHorizontalHints
      val verticalHintSectionSize =
        (fontSize + fontBorder) * maxNumberOfVerticalHints

      val withHints = new BufferedImage(
        gridImage.getWidth + verticalHintSectionSize,
        gridImage.getHeight + horizontalHintSectionSize,
        BufferedImage.TYPE_INT_ARGB
      )
      val g2 = withHints.createGraphics()

      // Draw existing grid
      g2.drawImage(gridImage, 0, horizontalHintSectionSize, null)

      // set up the font
      g2.setColor(Color.BLACK)
      g2.setFont(font)

      nonogram.horizontalHints.hints.zipWithIndex.foreach {
        case (hints, x) =>
          hints.zipWithIndex.foreach {
            case (hint, hintNumber) =>
              val xPos = x * cellSize
              val yPos = (fontSize + fontBorder) * (hintNumber + 1)
              g2.drawString(s"$hint", xPos, yPos)
          }
      }

      nonogram.verticalHints.hints.zipWithIndex.foreach {
        case (hints, y) =>
          hints.zipWithIndex.foreach {
            case (hint, hintNumber) =>
              val xPos =
                (nonogram.width * cellSize) + (fontSize * hintNumber) + (fontBorder * hintNumber + 1)
              val yPos = horizontalHintSectionSize + ((y + 1) * cellSize)
              g2.drawString(s"$hint", xPos, yPos)
          }
      }

      val finalImage: BufferedImage =
        (renderSolution, nonogram.solution) match {
          case (true, Some(solution)) =>
            val solutionImage = renderGrid(solution, cellSize)

            val borderSectionSize = fontSize + (fontBorder * 2)
            val combinedImage = new BufferedImage(
              withHints.getWidth,
              withHints.getHeight + solutionImage.getHeight + borderSectionSize,
              BufferedImage.TYPE_INT_ARGB
            )

            val combG2 = combinedImage.createGraphics()
            combG2.drawImage(withHints, 0, 0, null)
            combG2.setColor(Color.BLACK)
            combG2.drawString(
              "Solution:",
              fontBorder,
              withHints.getHeight + fontSize
            )
            combG2.drawImage(
              solutionImage,
              0,
              withHints.getHeight() + borderSectionSize,
              null
            )

            combinedImage
          case (false, _) | (true, None) => withHints
        }

      // finally write out the image
      ImageIO.write(finalImage, "png", outputStream)
    }

  private def renderGrid(
      grid: Grid,
      cellSize: Int
  ): BufferedImage = {
    // create the image

    val width  = grid.width
    val height = grid.height

    val imageWidth  = cellSize * width
    val imageHeight = cellSize * height

    val img = new BufferedImage(
      imageWidth,
      imageHeight,
      BufferedImage.TYPE_INT_ARGB
    )
    val g2 = img.createGraphics()

    var currentBg = emptyColours._1

    0.until(width).foreach { x =>
      0.until(height).foreach { y =>
        if (currentBg == emptyColours._1) currentBg = emptyColours._2
        else currentBg = emptyColours._1
        g2.setColor(currentBg)
        g2.fillRect(
          x * cellSize,
          y * cellSize,
          cellSize,
          cellSize
        )

        val square: Square = grid(x)(y)
        square match {
          case Blank =>
          case Occupied =>
            g2.setColor(filledColour)
            g2.fillRect(
              x * cellSize,
              y * cellSize,
              cellSize,
              cellSize
            )
          case Crossed =>
            g2.setColor(crossedColour)
            g2.drawLine(
              x * cellSize,
              y * cellSize,
              (x * cellSize) + cellSize,
              (y * cellSize) + cellSize
            )
            g2.drawLine(
              x * cellSize,
              (y * cellSize) + cellSize - 1,
              (x * cellSize) + cellSize - 1,
              y * cellSize
            )
        }
      }
    }

    img
  }
}
```

I actually built this using a lot of trial and error and a short test to render
out the resulting image as I went.

The basic algorithm I follow is:

1. Render the grid as an image
2. Figure out the extra space needed for the hints
3. Render the hints on another image and superimpose the grid onto this image
   as well
4. If there is a solution and rendering it is desired then render it as a grid
   and stick the two images together.

This all results in a rather nice image:

<img
  alt='The rendered Nonogram'
  src='{{ "assets/nonograms/test.png" | absolute_url  }}'
  class='blog-image'
/>

There is some room for improvement but overall I think that turned out rather
nicely!

So now I can do the following:

* Read Nonograms from a simple text format
* Write Nonograms to the same simple text format
* Write Nonograms out as an image

It might not seem like a lot but with how I have implemented these three I am
well on my way to being able to do more complex things with Nonograms. I could
now easily extend my code to:

* Read Nonograms from other formats
* Write Nonograms in other formats
* Generate Nonograms from images
* Solve Nonograms

All the framework is there for the first 2. The latter 2 would take some more
coding but are within reach. In fact I will probably write some other articles
on doing just these. I may not go into quite as much depth however, and in the
meantime will tidy my code somewhat.
