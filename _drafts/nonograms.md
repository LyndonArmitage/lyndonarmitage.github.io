---
layout: post
title: Nonograms Part 1
tags:
- nonogram
- puzzles
- programming
- bnf
---

I love [Nonograms](https://en.wikipedia.org/wiki/Nonogram)! As a puzzle I find
them very relaxing and meditative. They scratch the same itch as
[Sudokus](https://en.wikipedia.org/wiki/Sudoku) for me with less mathematical
thinking.

For those that don't know what a Nonogram is (and haven't followed that link),
they are simple puzzles where you are presented with a fixed sized grid and
some numbers encoding which squares are filled or not. Your task is to work out
from these numbers the exact placement of the filled and empty squares and
eventually create an image from them. They were invented separately by Tetsuya
Nishio and Non Ishida in the late 1980s.

For smaller grids this can be relatively easy but as you get larger and more
complicated it can become more and more difficult.

Below is the same example of a simple Nonogram that Wikipedia shows:

<table style="vertical-align:bottom">
<tbody><tr>
<td>
<table style="border-style:solid; border-width:1px; border-collapse:collapse; empty-cells:show; font-size:95%; line-height:1em; text-align:center;" rules="all">
<caption>empty Nonogram
</caption>
<tbody><tr style="background:#EFEFEF">
<td rowspan="2" colspan="2">
</td>
<td style="width:1em">
</td>
<td style="width:1em">
</td>
<td style="width:1em">
</td>
<td style="width:1em">2
</td>
<td style="width:1em">2
</td>
<td style="width:1em">
</td>
<td style="width:1em">
</td>
<td style="width:1em">
</td></tr>
<tr style="background:#EFEFEF">
<td>0</td>
<td>9</td>
<td>9</td>
<td>2</td>
<td>2</td>
<td>4</td>
<td>4</td>
<td>0
</td></tr>
<tr>
<td style="background:#EFEFEF"></td>
<td style="background:#EFEFEF">0</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td>
</td></tr>
<tr>
<td style="background:#EFEFEF"></td>
<td style="background:#EFEFEF">4</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td>
</td></tr>
<tr>
<td style="background:#EFEFEF"></td>
<td style="background:#EFEFEF">6</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td>
</td></tr>
<tr>
<td style="background:#EFEFEF">2</td>
<td style="background:#EFEFEF">2</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td>
</td></tr>
<tr>
<td style="background:#EFEFEF">2</td>
<td style="background:#EFEFEF">2</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td>
</td></tr>
<tr>
<td style="background:#EFEFEF"></td>
<td style="background:#EFEFEF">6</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td>
</td></tr>
<tr>
<td style="background:#EFEFEF"></td>
<td style="background:#EFEFEF">4</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td>
</td></tr>
<tr>
<td style="background:#EFEFEF"></td>
<td style="background:#EFEFEF">2</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td>
</td></tr>
<tr>
<td style="background:#EFEFEF"></td>
<td style="background:#EFEFEF">2</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td>
</td></tr>
<tr>
<td style="background:#EFEFEF"></td>
<td style="background:#EFEFEF">2</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td>
</td></tr>
<tr>
<td style="background:#EFEFEF"></td>
<td style="background:#EFEFEF">0</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td>
</td></tr></tbody></table>
</td>
<td style="width:2em">
</td>
<td>
<table style="border-style:solid; border-width:1px; border-collapse:collapse; empty-cells:show; font-size:95%; line-height:1em; text-align:center;" rules="all">
<caption>solved Nonogram
</caption>
<tbody><tr style="background:#EFEFEF">
<td rowspan="2" colspan="2">
</td>
<td style="width:1em">
</td>
<td style="width:1em">
</td>
<td style="width:1em">
</td>
<td style="width:1em">2
</td>
<td style="width:1em">2
</td>
<td style="width:1em">
</td>
<td style="width:1em">
</td>
<td style="width:1em">
</td></tr>
<tr style="background:#EFEFEF">
<td>0</td>
<td>9</td>
<td>9</td>
<td>2</td>
<td>2</td>
<td>4</td>
<td>4</td>
<td>0
</td></tr>
<tr>
<td style="background:#EFEFEF"></td>
<td style="background:#EFEFEF">0</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td>
</td></tr>
<tr>
<td style="background:#EFEFEF"></td>
<td style="background:#EFEFEF">4</td>
<td></td>
<td style="background:#000000">#</td>
<td style="background:#000000">#</td>
<td style="background:#000000">#</td>
<td style="background:#000000">#</td>
<td></td>
<td></td>
<td>
</td></tr>
<tr>
<td style="background:#EFEFEF"></td>
<td style="background:#EFEFEF">6</td>
<td></td>
<td style="background:#000000">#</td>
<td style="background:#000000">#</td>
<td style="background:#000000">#</td>
<td style="background:#000000">#</td>
<td style="background:#000000">#</td>
<td style="background:#000000">#</td>
<td>
</td></tr>
<tr>
<td style="background:#EFEFEF">2</td>
<td style="background:#EFEFEF">2</td>
<td></td>
<td style="background:#000000">#</td>
<td style="background:#000000">#</td>
<td></td>
<td></td>
<td style="background:#000000">#</td>
<td style="background:#000000">#</td>
<td>
</td></tr>
<tr>
<td style="background:#EFEFEF">2</td>
<td style="background:#EFEFEF">2</td>
<td></td>
<td style="background:#000000">#</td>
<td style="background:#000000">#</td>
<td></td>
<td></td>
<td style="background:#000000">#</td>
<td style="background:#000000">#</td>
<td>
</td></tr>
<tr>
<td style="background:#EFEFEF"></td>
<td style="background:#EFEFEF">6</td>
<td></td>
<td style="background:#000000">#</td>
<td style="background:#000000">#</td>
<td style="background:#000000">#</td>
<td style="background:#000000">#</td>
<td style="background:#000000">#</td>
<td style="background:#000000">#</td>
<td>
</td></tr>
<tr>
<td style="background:#EFEFEF"></td>
<td style="background:#EFEFEF">4</td>
<td></td>
<td style="background:#000000">#</td>
<td style="background:#000000">#</td>
<td style="background:#000000">#</td>
<td style="background:#000000">#</td>
<td></td>
<td></td>
<td>
</td></tr>
<tr>
<td style="background:#EFEFEF"></td>
<td style="background:#EFEFEF">2</td>
<td></td>
<td style="background:#000000">#</td>
<td style="background:#000000">#</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td>
</td></tr>
<tr>
<td style="background:#EFEFEF"></td>
<td style="background:#EFEFEF">2</td>
<td></td>
<td style="background:#000000">#</td>
<td style="background:#000000">#</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td>
</td></tr>
<tr>
<td style="background:#EFEFEF"></td>
<td style="background:#EFEFEF">2</td>
<td></td>
<td style="background:#000000">#</td>
<td style="background:#000000">#</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td>
</td></tr>
<tr>
<td style="background:#EFEFEF"></td>
<td style="background:#EFEFEF">0</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td>
</td></tr></tbody></table>
</td></tr></tbody></table>

I use the app from [Nonogram.com](https://nonogram.com/) on my Android and even
paid to remove the advertising from it. But you can find Nonograms printed in
many newspapers and collections of them in book stores.

Nonograms scratch that problem solving itch in my head and recently I have been
curious how easy it would be to computerise generating and solving them.
Normally the patterns they display represent some kind of image. For the
example above the letter P.

## First Steps: File Format

The first step in project like this is figuring out how you will represent a
Nonogram. You could store it in some kind of custom binary format or a text
readable format. Personally I like to lean towards the latter so that if I or
someone else ever comes across my files it's not too hard for them to
understand the format in isolation.

So looking at the example above we can see that we have:

* A grid of fixed dimensions
* Annotations on the rows
* Annotations on the columns
* Filled in or blank squares. Additionally I know from solving Nonograms that
  people often mark squares they know to be blank with crosses.

All of the above we need to encode into our format. Here was my first attempt
(for the example P Nonogram):

```txt
8x11
          2 2      
    0 9 9 2 2 4 4 0
0
4     # # # #
6     # # # # # #
2 2   # #     # #
2 2   # #     # #
6     # # # # # #
4     # # # #
2     # #
2     # #
2     # #
0
```

At first glance it looks pretty good and certainly fulfills the requirements
for the example Nonogram. However thinking about it as a computer this is not
the easiest thing to parse. This is because when parsing a text file you read
the text line by line.

In this format the first line denotes the size of the Nonogram, 8 squares long
and 11 squares tall. This is easily understood but then the subsequent lines
are much more difficult to program a machine to parse. We have a variable
amount of vertical and horizontal clues that are placed next to the actual
puzzle. In this example they are all single digits but they could easily be
more. So this is a great way to visualise the puzzle (at least for simple ones)
but a hard thing to parse.

As with most problems it's worth having a quick search to see if anyone else
has solved the same problem as you previously. A quick search reveals this to
be the case for representing Nonograms. [Steven
Simpson](https://scc-forge.lancaster.ac.uk/open/nonogram/contact) at the
University of Lancaster UK has a
[page](https://scc-forge.lancaster.ac.uk/open/nonogram/fmt2) on how he
represents Nonogram puzzles in the Nonogram solver he has published online. For
the example P Nonogram this would look like this:

```txt
width 8
height 11 

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
```

Of course this only represents the puzzle itself not the solution or filled in
squares on the grid. It's still a simple solution to the problem of representing
the row and column annotations.

Simpson's website also links to an [XML based
format](https://webpbn.com/pbn_fmt.html) published by [Jan
Wolter](https://unixpapa.com/), one of the founders of
[webpbn.com](https://webpbn.com/), a website dedicated to Paint By Numbers
puzzles (another name for Nonograms). XML formats are great, they force you to
follow strict patterns and there are XML parsers written for virtually every
programming language. However they also require a lot of prep work to parse and
can take up much more storage space as a result of all the extra tagging. So I
decided to keep looking at other formats.

[Rosetta Code](https://rosettacode.org/wiki/Nonogram_solver) contains a
challenge for writing a Nonogram solver that represents a puzzle in 3 different
ways.

First in graphical text:

```txt
Problem:                 Solution:

. . . . . . . .  3       . # # # . . . .  3
. . . . . . . .  2 1     # # . # . . . .  2 1
. . . . . . . .  3 2     . # # # . . # #  3 2
. . . . . . . .  2 2     . . # # . . # #  2 2
. . . . . . . .  6       . . # # # # # #  6
. . . . . . . .  1 5     # . # # # # # .  1 5
. . . . . . . .  6       # # # # # # . .  6
. . . . . . . .  1       . . . . # . . .  1
. . . . . . . .  2       . . . # # . . .  2
1 3 1 7 5 3 4 3          1 3 1 7 5 3 4 3
2 1 5 1                  2 1 5 1
```

Then as 2 lists:

```txt
x = [[3], [2,1], [3,2], [2,2], [6], [1,5], [6], [1], [2]]
y = [[1,2], [3,1], [1,5], [7,1], [5], [3], [4], [3]]
```

And finally as 2 more compact strings where letters stand in for numbers:

```txt
x = "C BA CB BB F AE F A B"
y = "AB CA AE GA E C D C"
```

The first format is visually pleasing and similar to my first thought of a
format. You can count the number of `.` symbols to ascertain the width of a
puzzle and because the annotations are presented at the end of the line and
file they do not interfere with the grid. We still have the potential issue
with the vertical annotations greater than a single digit misaligning however.

The second format is hard for a human to parse but very simple for a computer.

The third is even harder for a human to understand, at least at first glance,
but is very compact.

I am not a fan of the Rosetta Code formats so I looked some more and found that
there is an R package that represents Nonogram puzzles published by
[@coolbutuseless](https://coolbutuseless.github.io/2018/09/26/nonograms-in-r-nonogram-package/).

The puzzles are represented by terse "human-friendly" strings like:

```txt
3:2,1:3,2:2,2:6:1,5:6:1:2-1,2:3,1:1,5:7,1:5:3:4:3
```

These separate each row or column by a `:` symbol and use the `,` symbol to
denote groups of numbers per row or column. The `-` symbol is then used to
split the string into row and column entries.

This format is far from what I wanted but it shows you can solve a problem in
many ways!

Going back to the original problem all these formats solve representing the
puzzle and grid size but none of them solve having filled in squares (except
maybe the XML format). And most aren't the most readable. So it was time for
some more thought and experimentation.

First let's take my original idea and force myself to use `.` for every blank
symbol. This would be a little easier to parse.

```txt
8x11
          2 2      
    0 9 9 2 2 4 4 0
0   . . . . . . . .
4   . # # # # . . .
6   . # # # # # # .
2 2 . # # . . # # .
2 2 . # # . . # # .
6   . # # # # # # .
4   . # # # # . . .
2   . # # . . . . .
2   . # # . . . . .
2   . # # . . . . .
0   . . . . . . . .

```

However this still suffers from having the hints at the front of the rows and
columns so let's flip them around like the Rosetta Code example:

```txt
8x11
. . . . . . . . 0   
. # # # # . . . 4   
. # # # # # # . 6   
. # # . . # # . 2 2 
. # # . . # # . 2 2 
. # # # # # # . 6   
. # # # # . . . 4   
. # # . . . . . 2   
. # # . . . . . 2   
. # # . . . . . 2   
. . . . . . . . 0   
0 9 9 2 2 4 4 0
      2 2       
```

Still suffering from that potential problem with the column digits being more
than one. We could solve this by elongating the columns where this happens but
that could look quite ugly and lead to some potential problems parsing e.g.

```txt
8x11
#  # # # # # # #  8   
#  . . . . . . #  0
#  . . . . . . #  0
#  . . . . . . #  0
#  . . . . . . #  0
#  . . . . . . #  0
#  . . . . . . #  0
#  . . . . . . #  0 
#  . . . . . . #  0 
#  . . . . . . #  0
#  # # # # # # #  8   
11 0 0 0 0 0 0 11
```

So let's take a leaf out of Simpson's book and bin alignment of the annotations
altogether. Instead we can print them out separately:

```txt
8x11

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

It's much less compact but it does allow us to store both the puzzle and any
extra hints, even the solution if we desire. This kind of format is also
eminently readable by a human being and computer. You can easily devise an
algorithm in almost any programming language to parse and write it.

Let's extend it a little more, we'll add some additional, but optional,
sections including the solution section and some metadata about the puzzle:

```txt
8x11

title
Wikipedia P Nonogram

author
Unknown

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

That is looking very promising, I even altered the grid section to include
hints rather than the full solution.

Let's take apart this format and try to define it in words rather than by
example. In programming there is a syntax called [Backus-Naur form
(BNF)](https://en.wikipedia.org/wiki/Backus%E2%80%93Naur_form) that can be used
to give exact descriptions of languages and files. BNF, or something similar,
is often used when defining programming language syntax or in technical
documentation e.g. for postal codes. We can define our file format using BNF or
better yet EBNF (extended Backus-Naud form), a slightly less verbose format.
However it would be difficult for someone unfamiliar with it to follow so let's
start with a plain English description then move onto the EBNF:

* The first line of our format defines the dimensions of the Nonogram in the
  format `[rows]x[columns]` for example a 10 by 10 Nonogram would be `10x10`
  and a Nonogram with 10 rows and 5 columns would be `10x5`
* The rest of the sections are started with a keyword and new line, keywords
  include:
  * title
  * author
  * rows
  * columns
  * grid
  * solution
* Each section should only appear once.
* The following sections are mandatory:
  * rows
  * columns
* rows and columns sections must match with the defined dimensions of the
  Nonogram
* Each entry in a section is delineated by a new line
* Sections should be separated by an empty line before the next section keywords
* Column entries go from left to right
* Row entries go from top to bottom
* Row and Column entries use the `,` symbol to divide between separate entries
  for their respective row or column
* The grid and solution sections are visual representations of the initially
  presented grid and solution respectively
* Each line in the solution and grid sections represents a single row of the
  from top to bottom.
* The following symbols are valid for the grid and solution sections
  * A space represents the gap between 2 squares
  * `.` represents an empty square
  * `#` represents an occupied square
  * `X` represents an empty square marked as empty
* The `X` and `.` are equivalent in the solution section

That's very long and it's probably still missing some details and could be
ambiguous in places. Encoded in EBNF this would look something like the
following:

```ebnf
(* Our dimension is rather simple *)
dimension = integer, "x", integer;

(* Our sections *)
section = (required_section | optional_section), "\n", section_entries, "\n";
required_section = "rows" | "columns";
optional_section = "title" | "author" | "grid" | "solution";

(* A section can either be text, numerical or a grid *)
section_entries = numeric_section_rows | grid_rows | text_row;

(* Representing simple text sections *)
text_row = text, "\n";

(* Representing the rows and column entries *)
numeric_section_rows = numeric_section_row | numeric_section_rows;
numeric_section_row = numeric_section_entry, "\n";
numeric_section_entry = integer | numeric_section_entry, ",";

(* The grid is made up of rows *)
grid_rows = grid_row | grid_rows;
grid_row = grid_row_entry "\n";
grid_row_entry = grid_square | grid_row_entry, grid_separator;

(* Our grid symbols *)
grid_square = empty_square | occupied_square | empty_marked_square;
grid_separator = " ";
empty_square = ".";
occupied_square = "#";
empty_marked_square = "X";

(* In BNF we need to describe what an integer is *)
integer = digit | integer, digit;
digit = "0" | digit_excluding_zero;
digit_excluding_zero = "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9";

(* We also need to describe what text is *)
text = character | text;
character = letter | symbol | digit;
letter = "A" | "B" | "C" | "D" | "E" | "F" | "G" | "H" | "I" | "J" 
       | "K" | "L"| "M" | "N" | "O" | "P" | "Q" | "R" | "S" | "T" 
       | "U" | "V" | "W" | "X" | "Y" | "Z" | "a" | "b" | "c" | "d" 
       | "e" | "f" | "g" | "h" | "i" | "j" | "k" | "l" | "m" | "n" 
       | "o" | "p" | "q" | "r" | "s" | "t" | "u" | "v" | "w" | "x" 
       | "y" | "z";
symbol = "|" | " " | "!" | "#" | "$" | "%" | "&" | "(" | ")" | "*" 
       | "+" | "," | "-" | "." | "/" | ":" | ";" | ">" | "=" | "<" 
       | "?" | "@" | "[" | "\" | "]" | "^" | "_" | "`" | "{" | "}" 
       | "~" | '"' | "'";
```

I may have made some mistakes in there and it's not *very* readable but to a
machine this kind of definition is much less ambiguous than the human readable
text I wrote and, to someone familiar with EBNF it conveys just as much
information.

Now we have settled on a format we need to start thinking about how our program
will parse it and represent it in memory. And since this blog post has gotten
rather long and technical I will divide that into the next post in this series.
