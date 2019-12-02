---
layout: post
title: Advent of Code 2019 Day 2
tags: [scala, advent of code]
---

This year I have decided to try and do the code challenges on the
[Advent of Code](https://adventofcode.com/) website in Scala and possibly Spark
if needed (or an interesting solution arises).  
These are simple little coding challenges given once per day like an Advent
Calendar before Christmas.

I am starting a day late on the 2nd of December, but this hopefully means my
solutions will not spoil it for anyone else!

## [Day 2](https://adventofcode.com/2019/day/2): Part 1

This days challenge is quite different to Day 1 and involves creating a simple
interpreter or emulator for processing a simple input program and set of
opcodes.

I have decided not to copy and paste the whole challenge here for brevity's sake
but I will refer back to parts. I encourage you to read the
[whole challenge](https://adventofcode.com/2019/day/2) before continuing.

We are tasked with building a "computer" to interpret "Intcode" programs:

> An Intcode program is a list of integers separated by commas
> (like `1,0,0,3,99`).
> To run one, start by looking at the first integer (called position 0).
> Here, you will find an opcode - either `1`, `2`, or `99`.
> The opcode indicates what to do; for example, `99` means that the program is
> finished and should immediately halt.
> Encountering an unknown opcode means something went wrong.

We are provided with 3 opcodes in this part of the task, `1`, `2`, and `99`.  

Opcode `1` does the following:

> Opcode 1 adds together numbers read from two positions and stores the result
> in a third position.
> The three integers immediately after the opcode tell you these three
> positions - the first two indicate the positions from which you should read
> the input values, and the third indicates the position at which the output
> should be stored.

And opcode `2` does:

> Opcode 2 works exactly like opcode 1, except it multiplies the two inputs
> instead of adding them. Again, the three integers after the opcode indicate
> where the inputs and outputs are, not their values.

With opcode `99` halting the program.

We are also told how to move on to the next operation when done calculating the
current opcode:

> Once you're done processing an opcode, move to the next one by stepping
> forward 4 positions.

It is useful to note that all opcodes and data in this task appears to be
integers.

It is also useful to realise that from the description of this task we are
actually implementing a very simple computer with
[Von Neumann architecture](https://en.wikipedia.org/wiki/Von_Neumann_architecture),
that is, a computer where program input and output and program instructions are
stored within the same space, and is the basis of most common computers in use
today.  
An interesting side-effect of this architecture is that code can be self
modifying.

As part of this task we are given some example inputs and their eventual outputs
which will be useful when testing our implementation:

> Here are the initial and final states of a few more small programs:
>
> * `1,0,0,0,99` becomes `2,0,0,0,99` (1 + 1 = 2).
> * `2,3,0,3,99` becomes `2,3,0,6,99` (3 * 2 = 6).
> * `2,4,4,5,99,0` becomes `2,4,4,5,99,9801` (99 * 99 = 9801).
> * `1,1,1,4,99,5,6,0,99` becomes `30,1,1,4,2,5,6,0,99`.

Our overall task is given at the end as:

> Once you have a working computer, the first step is to restore the gravity
> assist program (your puzzle input) to the "1202 program alarm" state it had
> just before the last computer caught fire.
> To do this, *before running the program*, replace position `1` with the
> value `12` and replace position `2` with the value `2`.
> *What value is left at position `0`* after the program halts?

### Implementing the Computer

We first need to read in the input program and convert it into a structure our
program can use.

```scala
import scala.io.Source

val filename = "day2.input.txt"
// Open the input file
val bufferedSource = Source.fromFile(filename)

// Convert the contents into our opcodes
val originalOpcodes: Array[Int] = bufferedSource.mkString
  .trim
  .split(',')
  .map(string => string.toInt)

// Close the input file
bufferedSource.close()
```

This code will convert the input file into an array of integers ready for us
to work with.  
The `mkString` method will load the whole contents of the file into a string
then the `trim` method removes any trailing spaces, with the `split` and `map`
methods dividing the string up on the commas and converting that output to
integers.

Now with our 3 given opcodes we should define some kind of structure to make
calculating them easier.
Since this is a quick puzzle I will opt for defining a simple functions and will
also use the scala `type` keyword to try and make my code easier to understand.

I will be making use of Scala's mutable indexed type `mutable.IndexedSeq` to
store the working memory of the program that will be read and modified by each
operation:

```scala
type Memory = Array[Int]
type Position = Int
type Opcode = Int

// Simple Operation type:
// Taking in the current memory state and position and outputting the new
// state and position
type Operation = (Memory, Position) => (Memory, Position)
```

Now I can create a simple lookup table of opcodes and their operations:

```scala
type Memory = mutable.IndexedSeq[Int]
type Opcode = Int

// Simple Operation type:
// Taking in the current position in memory and memory itself and outputting
// the new position and whether this operation should halt or not.
type Operation = (Int, Memory) => (Int, Boolean)

// The add operation
val addOp: Operation = (pos: Int, memory: Memory) => {
  val inputAddress1 = memory(pos + 1)
  val inputAddress2 = memory(pos + 2)
  val outputAddress = memory(pos + 3)
  memory(outputAddress) = memory(inputAddress1) + memory(inputAddress2)
  (pos + 4, false)
}

// The multiply operation
val multiplyOp: Operation = (pos: Int, memory: Memory) => {
  val inputAddress1 = memory(pos + 1)
  val inputAddress2 = memory(pos + 2)
  val outputAddress = memory(pos + 3)
  memory(outputAddress) = memory(inputAddress1) * memory(inputAddress2)
  (pos + 4, false)
}

// The simple halting operation
val haltOp: Operation = (pos: Int, memory: Memory) => {
  (pos, true)
}

// The map of opcodes to their operations
val opcodeMap = Map[Opcode, Operation](
  (1, addOp),
  (2, multiplyOp),
  (99, haltOp)
)
```

Now we have a simple map of opcodes to their operations we need to write the
code to execute them:

```scala
val errorOp: Operation = (pos: Int, memory: Memory) => {
  val opcode = memory(pos)
  println(s"Unknown opcode encountered at $pos: $opcode")
  (pos, true)
}

@scala.annotation.tailrec
def iterate(pos: Int, memory: Memory): Unit = {
  val opcode = memory(pos)
  val operation = opcodeMap.getOrElse(opcode, errorOp)
  val (newPos, shouldHalt) = operation(pos, memory)
  if (shouldHalt) {
    return
  }
  iterate(newPos, memory)
}
```

This method will take in a position in memory and the memory itself and execute
opcodes on it until it reaches an operation that will cause it to halt.  
I have done this using the Tail Recursion support in Scala to make it easy to
read. This will avoid stack overflow issues.

I have also added an error operation that will be executed upon hitting an
unknown opcode.

We can test one of the examples:

```scala
val mainMemory: Memory = mutable.IndexedSeq(2,4,4,5,99,0)

iterate(0, mainMemory)

val finalOutput = mainMemory.mkString(",")
println(finalOutput)
```

This will output: `2,4,4,5,99,9801`

We can run this with the file contents my copying the original code to the
memory variable:

```scala
val mainMemory: Memory = mutable.IndexedSeq(originalOpcodes: _*)
```

Of course the task also instructs us to fix the program:

> To do this, *before running the program*, replace position `1` with the
> value `12` and replace position `2` with the value `2`.

```scala
mainMemory(1) = 12
mainMemory(2) = 2
```

Then execute it.  
And we have the answer to the puzzle in index 0.

## Day 2: Part 2

The second part of the day requires us to figure out the inputs to the program
that will result in an expected value.

> "With terminology out of the way, we're ready to proceed.
> To complete the gravity assist, you need to determine what pair of inputs
> produces the output `19690720`."

Something important noted in the puzzle is that opcodes can move the position
in memory a variable amount of steps depending on what instructions there are:

> The address of the current instruction is called the instruction pointer;
> it starts at 0.
> After an instruction finishes, the instruction pointer increases by the
> number of values in the instruction; until you add more instructions to the
> computer, this is always 4 (1 opcode + 3 parameters) for the add and multiply
> instructions. (The halt instruction would increase the instruction pointer
> by 1, but it halts the program instead.)

This actually means our halt instruction should technically look like:

```scala
val haltOp: Operation = (pos: Int, memory: Memory) => {
  (pos + 1, true)
}
```

The following extra details are provided to narrow down the search:

> The inputs should still be provided to the program by replacing the values at
> addresses 1 and 2, just like before.
> In this program, the value placed in address 1 is called the noun, and the
> value placed in address 2 is called the verb.
> Each of the two input values will be between 0 and 99, inclusive.

This narrows down our search somewhat.

To repeat what we need to do is:

> Find the input noun and verb that cause the program to produce the output
> `19690720`. What is `100 * noun + verb`?
> (For example, if noun=`12` and verb=`2`, the answer would be 1202.)

It is also suggested that we should make sure to reset the memory to the
original opcodes before each attempt.

To this end we can write a function to make it easier to test various inputs:

```scala
def decode(noun: Int, verb: Int, originalMemory: IndexedSeq[Int]): Int = {
  val mainMemory: Memory = mutable.IndexedSeq(originalMemory: _*)
  mainMemory(1) = noun
  mainMemory(2) = verb
  iterate(0, mainMemory)
  mainMemory(0)
}
```

This will execute for the given noun and verb pair and output the result.

We can then brute force the answer to the puzzle:

```scala
val random = scala.util.Random
var output: Int = 0
var noun: Int = 0
var verb: Int = 0
while (output != 19690720) {
  noun = random.nextInt(100)
  verb = random.nextInt(100)
  output = decode(noun, verb, originalOpcodes)
}
println(s"noun=$noun verb=$verb")
val answer = 100 * noun + verb
println(answer)
```

And this will output the solution to part 2!
