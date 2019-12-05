---
layout: post
title: Advent of Code 2019 Day 3
tags: [scala, advent of code]
---

This year I have decided to try and do the code challenges on the
[Advent of Code](https://adventofcode.com/) website in Scala and possibly Spark
if needed (or an interesting solution arises).  
These are simple little coding challenges given once per day like an Advent
Calendar before Christmas.

I did complete this challenge on the day but am only now managing to write
about it!

## [Day 3](https://adventofcode.com/2019/day/3): Part 1

Today's challenge is again slightly more difficult than previous days.  
I will again only try to paste the relevant parts of the challenge here.

We are presented with input that describes 2 wires coming out of a port and
snaking around a grid.

> Specifically, two wires are connected to a central port and extend outward
> on a grid.
> You trace the path each wire takes as it leaves the central port, one wire
> per line of text (your puzzle input).

And our job is to find the closest point they cross:

> To fix the circuit, you need to find the intersection point closest to the
> central port. Because the wires are on a grid, use the Manhattan distance for
> this measurement. While the wires do technically cross right at the central
> port where they both start, this point does not count, nor does a wire count
> as crossing with itself.

Manhattan distance is a common distance metric used when dealing with grids and
is also known as "[Taxicab Geometry](https://en.wikipedia.org/wiki/Taxicab_geometry)"
because of the fact you measure the same way as a taxi would navigate through a
city like Manhattan (a grid based city).  
That means you measure your distance in each axis and add them up.  
For example if you are at position `(0, 1)` and want to get to `(10, 9)` you
take the `x` components and find the difference, `0 to 10 = 10`, and do the same
with the `y` components, `1 to 9 = 8`, and add those results together,
`8 + 10 = 18`, and that is your Manhattan distance.

The wire paths are describe using what are essentially commands, for example:

> For example, if the first wire's path is `R8,U5,L5,D3`, then starting from the
> central port (o), it goes right 8, up 5, left 5, and finally down 3:

```
...........
...........
...........
....+----+.
....|....|.
....|....|.
....|....|.
.........|.
.o-------+.
...........
```

> Then, if the second wire's path is `U7,R6,D4,L4`, it goes up 7, right 6,
> down 4, and left 4:

```
...........
.+-----+...
.|.....|...
.|..+--X-+.
.|..|..|.|.
.|.-X--+.|.
.|..|....|.
.|.......|.
.o-------+.
...........
```

> These wires cross at two locations (marked X), but the lower-left one is
> closer to the central port: its distance is `3 + 3 = 6.`

So to begin we will need to be able to read and represent the wires in the text
file.

I begin by creating some data structures to do this:

```scala
import scala.collection._

object Direction extends Enumeration {
  type Direction = Value
  val UP = Value("U")
  val RIGHT = Value("R")
  val DOWN = Value("D")
  val LEFT = Value("L")
}

import Direction.Direction

case class Command(direction: Direction, distance: Int)

type Wire = Seq[Command]
```

Here I have defined the direction as an enumerated type and commands as being a
combination of directions and distance, with a wire simply being an ordered
sequence of commands.

Now for parsing and reading I will again be using the Scala Source class and
split this into several function to make it easier to read and think about the
code:

```scala
def parseCommand(command: String): Option[Command] = {
  if (command.length < 2) {
    return None
  }
  try {
    val direction = Direction.withName(command.substring(0, 1))
    val distance = command.substring(1).toInt
    Some(Command(direction, distance))
  } catch {
    case _: Exception =>
      println(s"Unhandled command: $command")
      None
  }
}
```

First up I think about how I want to handle parsing a single command from the
file I am given. These will be in forms similar to `U1`, `R12`, `D3` and `L23`,
basically a letter denoting direction followed by an integer denoting distance.  
In my Direction enumerated object I defined each direction to have a name
corresponding to the letters used in the input. I take the first character of
the command and attempt to match it, then take the remainder and attempt to
convert it to an integer.  
If something goes wrong with the parsing I return a `None` that I can handle
later and log the bad command.

```scala
def parseLine(line: String): Option[Wire] = {
  if (line == null || line.isEmpty) {
    return None
  }
  val commands: Seq[Option[Command]] = line.split(',')
    .map(part => parseCommand(part))

  if (commands.forall(item => item.isDefined)) {
    Some(commands.flatten)
  } else {
    println(s"Unhandled line: $line")
    None
  }
}

import scala.io.Source

def readInput(filename: String): Seq[Wire] = {
  val source = Source.fromFile(filename)
  val wires = source.getLines()
    .map(line => line.trim)
    .filter(line => line.nonEmpty)
    .map(line => parseLine(line))

  wires.flatten.toSeq
}
```

The next function is for parsing a whole line.  
It splits the line up on the comma separator and uses the first function to
extract a command from it.  
It then checks all the results of parsing and sees if there were any errors with
the command parsing. If there were it returns a `None` and logs an error,
otherwise it flattens out all the `Some[Command]` instances into `Command`
instances.

Finally there is the `readInput` function that actually opens the file, reads
it line by line and uses the `parseLine` method to generate whole wires.

With all that done we can now represent our wires in a way we can easily
manipulate. It's now time to consider how to determine where on a grid the
wires actually live!  
For this we need to represent positions somehow:

```scala
type Position = (Int, Int)
```

For now this simple tuple will suffice.

Now we need to convert the commands that make up a wire and convert them into
all the positions they sit on a grid.  
With our data structures this can be relatively simple:

```scala
def addCommand(start: Position, command: Command): Position = {
  val Command(direction: Direction, distance: Int) = command
  if (distance == 0) {
    return start
  }
  val (x, y) = start

  direction match {
    case Direction.UP => (x, y + distance)
    case Direction.DOWN => (x, y - distance)
    case Direction.RIGHT => (x + distance, y)
    case Direction.LEFT => (x - distance, y)
  }
}
```

The way this function works is that given a starting position and command it
will determine where the command would cause the position to move to and return
that as a result.

Of course if I used just this method I would only end up with positions where
the wire changed direction (or got a new command), not all the points in between
these positions.  
For this reason I need a method of getting all the points between the starting
position and the ending position of a command:

```scala
def pointsBetween(start: Position, end: Position): Seq[Position] = {
  val results = mutable.Buffer[Position]()
  val (x0, y0) = start
  val (x1, y1) = end
  val xStep = if (x0 > x1) -1 else 1
  val yStep = if (y0 > y1) -1 else 1
  for (x <- x0.to(x1, xStep)) {
    for (y <- y0.to(y1, yStep)) {
      val pos: Position = (x, y)
      // Don't add the start to the results
      if (x != x0 || y != y0) {
        results += pos
      }
    }
  }
  results
}
```

This method is relatively simple again, it's basic interpolation between the
two points.  
I make use of a mutable Scala `Buffer` here to make things easier to read.

Now that I can get the points between 2 points I can bring this altogether to
get all the points in a wire:

```scala
def getPositions(wire: Wire, origin: Position = (0, 0)): Seq[Position] = {
  val positions = mutable.Buffer[Position]()
  var lastPosition: Position = origin
  for (command <- wire) {
    val firstPosition: Position = lastPosition
    lastPosition = addCommand(firstPosition, command)
    // add all points between start (exclusive) and end (inclusive)
    positions ++= pointsBetween(firstPosition, lastPosition)
  }

  positions
}
```

This function starts at an origin and executes each command, using the start
and end points of each, adding them all to a buffer and returning them all.

Now we can get all the points in a wire we need a way of finding out when wires
intersect each other.  
This is actually pretty simple:

```scala
def findIntersections(paths: Seq[Seq[Position]]): Seq[Position] = {
  val positionCounts: Map[Position, Int] =
    paths.flatMap(path => path.distinct)
      .groupBy(identity)
      .mapValues(_.size)

  positionCounts.filter(entry => entry._2 > 1).keys.toSeq
}
```

Since each path a wire takes now contains all the positions a wire can be in we
just need to find where a position exists in both wires paths.  
I have done this using some standard Scala code;  

1. First I get a distinct list of all positions in each path, that way I can
   avoid counting a wire crossing itself.
2. Then I use flatmap to combine the paths into one list.
3. Then I group them all by themselves (that's the `identity` method I use) and
   convert the list into a `Map[Position, Int]` with the values being the count
   of occurrences of a given position.

This resulting map contains all the positions in both paths, if I then filter
it down to only those that have a count greater than 1 I can find any
intersections.

I can use the above methods to get me this far like so:

```scala
val wires = readInput("day3.input.txt")
val wireToPositions = wires.map(wire => (wire, getPositions(wire))).toMap
val intersections = findIntersections(wireToPositions.values.toSeq)
```

Now I need to actually use the manhattan distance to find out which of the
intersections is the closest.  
The code fot the manhattan distance in Scala is simple:

```scala
def manhattanDistance(origin: Position, other: Position): Int = {
  val x: Int = math.abs(origin._1 + other._1)
  val y: Int = math.abs(origin._2 + other._2)
  x + y
}
```

I can then find the closest intersection like so:

```scala
def findClosestIntersection(
    origin: Position,
    intersections: Seq[Position]
    ): (Position, Int) = {
  val withDistances =
    intersections.map(pos => (pos, manhattanDistance(origin, pos)))

  withDistances.minBy(f => f._2)
}
```

What this does is similar to finding the intersections initially; it takes each
position and gets it's distance from the origin, then simply returns the one
with the smallest distance.

I can then use this command like so to answer part 1:

```scala
val closest = findClosestIntersection(
  (0, 0),
  intersections
)
println(s"Closest intersection ${closest._1} distance=${closest._2}")
```

## Day 3: Part 2

Finally onto part 2.  
We now need to use a different measurement on the intersections:

> To do this, calculate the number of steps each wire takes to reach each
> intersection; choose the intersection where the sum of both wires' steps is
> lowest. If a wire visits a position on the grid multiple times, use the
> steps value from the first time it visits that position when calculating the
> total value of a specific intersection.
>
> The number of steps a wire takes is the total number of grid squares the wire
> has entered to get to that location, including the intersection being
> considered. Again consider the example from above:

```
...........
.+-----+...
.|.....|...
.|..+--X-+.
.|..|..|.|.
.|.-X--+.|.
.|..|....|.
.|.......|.
.o-------+.
...........
```

> In the above example, the intersection closest to the central port is
> reached after `8+5+5+2 = 20 steps` by the first wire and `7+6+4+3 = 20 steps`
> by the second wire for a total of `20+20 = 40 steps`.
>
> However, the top-right intersection is better: the first wire takes only
> `8+5+2 = 15` and the second wire takes only `7+6+2 = 15`, a total of 
> `15+15 = 30 steps`.

With our code this is actually pretty easy.  
Since we have a list of all the positions in a wire we can use it with the
intersections we uncovered before to find out their distances by simply counting
the steps it takes to get to them:

```scala
val wireToIntersectionDistances: Map[Wire, Map[Position, Int]] =
  wireToPositions.map(entry => {
    val wire = entry._1
    val positions = entry._2
    val positionsToDistance = intersections.map(
      // remember to +1 as we excluded the origin from our original list
      intersection => (intersection, positions.indexOf(intersection) + 1)
    ).toMap
    (wire, positionsToDistance)
  })
```

Then with this map of wires to their intersections and their distances we can
do some more calculations to find out the total steps taken from both wires for
each intersection and then find the lowest:

```scala
val intersectionsToTotalDistances: Map[Position, Int] =
  wireToIntersectionDistances.foldLeft(Map[Position, Int]())((sum, map) => {
    val otherMap = map._2
    (sum.keySet ++ otherMap.keySet).map { key: Position =>
      (key, sum.getOrElse(key, 0) + otherMap.getOrElse(key, 0))
    }.toMap
  })

val minDistanceIntersection = intersectionsToTotalDistances.minBy(f => f._2)

println(s"Min distance intersection at ${minDistanceIntersection._1} distance=${minDistanceIntersection._2}")
```

Now admittedly that `foldLeft` block of code does look quite complex but what
it does is fairly simple:

1. The first set of arguments contains the initial, empty, value for what we
    want to eventually return, a map of positions to the total amount of steps
    taken.
2. The next set of arguments contains the function that keeps the running
   summarized map and the current map being processed from the
   `wireToIntersectionDistances` map entries.
3. The rest of the code then sums up the maps values within based on their keys,
   which are the positions.
4. Finally we get the minimum entry like before.

And that's part 2 of Day 3 done!
