---
layout: post
title: HTML5 Pokemon Save File Viewer
tags: [blog, blogger, emulator, html5, javascript, pokemon]
---

<p class="message">
This was a blog post originally published in 2014 on
<a href="https://web.archive.org/web/20160319034226/http://lyndonarmitage.com/html5-pokemon-save-file-viewer/">Blogger</a>.<br />
I have resurrected it for posterity, there are other posts from my Blogger
that have since disappeared.<br />
This
<a href="https://github.com/LyndonArmitage/HTML5PokemonSaveReader">repository</a>
is also one of my most popular ones on GitHub, a live version of the viewer
can be seen
<a href="{{ "assets/html5-pokemon-save-reader/" | absolute_url }}">here</a>.
</p>

___Note:___ I initially slated this blog post to be posted months ago but from the
looks of it never got round to finishing it, as such some of the details might
be slightly out of date or incomplete.
I have gone through quickly and tried to make sure things make sense.

For quite a while I have been working on a personal project involving JavaScript,
the new HTML5 File API and an interest in emulation using JavaScript and HTML5.

The project I have been working in is a Save File Reader written for the first
generation of Pokémon games.

Initially I wanted to try my hand at writing a Game Boy emulator in JavaScript,
but after a bit of research I decided I should probably start smaller.
Having been familiar with the first generation of Pokémon games (I grew up
with them) and having access to some references on the save file format used
along with ROM copies of the cartridges I own I decided to put some of the
research I had done into the HTML5 File API to use in the hopes that it
would help me learn a bit more about how to use, how older games stored their
save data and give me some practice at creating tools.

This blog post details my foray into the creation and development of my first
generation Pokémon save file reader.

## Preparation

The first thing I needed was a game to target and a save file to use,
I chose Pokémon Yellow as I already had the ROM file and had played on and
off with the original cartridge earlier in the year (exploring some of
the bugs and exploits in the game).

The next thing I needed was a reference to the Save File format/structure
used, luckily there are a lot of resources around in regards to the Pokémon
franchise, the go to place from the look of it is called
[Bulbapedia](http://bulbapedia.bulbagarden.net/);
for a reference on the save file format specifically, this
[page](http://bulbapedia.bulbagarden.net/wiki/Save_data_structure_in_Generation_I).

The page in question maps out most of the important parts of the save file
format and links to other relevant pages that describe how the Pokémon data
structures work and many other mechanics and internals of the first generation
of Pokémon games (a goldmine of information if you are into that sort of thing,
or want to learn about some of the problems with the first generation and how
they were addressed in later generations).

Armed with this reference, a hex editor (I use a free one called
[xvi32](http://www.chmaas.handshake.de/delphi/freeware/xvi32/xvi32.htm)) I
began a new game in Pokémon Yellow on an emulator (I used
[Visual Boy Advance](http://vba.ngemu.com/), purely due to familiarity with it;
for any real fiddling with gameboy game internals you should have a look at
[BGB](http://bgb.bircd.org/)).
Using my hex editor I started poking and prodding the save files it made in an
attempt to make sure the data was in the same place as described by the
reference I was using (it always pays to be sure), once satisfied I started
coding my HTML and JavaScript Files.

## The Coding

Initially I decided not to make use of any external JavaScript libraries and
only use functions and objects available to me in a browser environment.
I quickly decided to go back on this and make use of jQuery since I wanted to
familiarize myself with it and it had several capabilities that I wanted to
take advantage of, still I wanted to divorce as much of the code as I could
from the library so abstracted out my front end from the guts of the save file
parser I wanted to create.

### Loading the Save Files and Validating

The first thing I decided to program, for obvious reasons, was the
choosing/loading of the save file. I opted to use the HTML5 File API since it
allows me to get access to a given file on the user’s file system without the
need to upload it to a server and write a server side parser (when I started
this project I had not even considered node.js).
This was as simple as checking that the user’s browser supported the
HTML5 File API and if so binding an event to an input element.
To read the file I needed to make use of a FileReader object and it’s method
`readAsBinaryString`; this let’s you read the value of each byte in a file as
a string, utilizing this and the offsets described in the reference I linked
to earlier I was able to read the data from the save file correctly.

Using the HTML5 File API also gets around any legal issues that could arise
from hosting the save files, although as far as I am aware there are none,
it also means that I do not need to keep a copy of the uploaded save file,
cutting down on space used.

Next up was validating that the given file was in fact a save file, I did this
in two ways; first I check the size of the file is 32KB and then I check that
the file ends with .sav. There is still a chance that you can use a bogus file,
in which case you would get garbage data out (garbage in, garbage out), but
these two simple conditions prevent the user from accidentally crashing their
browser by choosing a huge file (as the project currently reads the entire file
into a string as described above) and from choosing a file with the incorrect
extension.

With validation done it was finally time to read some real data from the save
file, so what did I think should be first? The player's name!

### Reading the Player's name (and other Text Strings)

Text data in the first generation of Pokémon games is stored using a
[proprietary character set](http://bulbapedia.bulbagarden.net/wiki/Save_data_structure_in_Generation_I#Text_data).
Each character is represented by 1 byte in a range from `0x0` to `0xFF`
(that is 0 to 255 in regular, non hexadecimal numbers).
The table below has been copied from Bulbapedia and describes what each
character is mapped to in the character set.

<table>
<tbody>
<tr>
<th></th>
<th>-0</th>
<th>-1</th>
<th>-2</th>
<th>-3</th>
<th>-4</th>
<th>-5</th>
<th>-6</th>
<th>-7</th>
<th>-8</th>
<th>-9</th>
<th>-A</th>
<th>-B</th>
<th>-C</th>
<th>-D</th>
<th>-E</th>
<th>-F</th>
</tr>
<tr>
<td><b>0-<br>
1-<br>
2-<br>
3-<br>
4-<br>
5-<br>
6-<br>
7-</b></td>
<td colspan="16"><i>Unused, except for:</i><br>
0x50 <i>(terminator) and</i><br>
0x7F <i>(space)</i></td>
</tr>
<tr>
<td><b>8-</b></td>
<td>A</td>
<td>B</td>
<td>C</td>
<td>D</td>
<td>E</td>
<td>F</td>
<td>G</td>
<td>H</td>
<td>I</td>
<td>J</td>
<td>K</td>
<td>L</td>
<td>M</td>
<td>N</td>
<td>O</td>
<td>P</td>
</tr>
<tr>
<td><b>9-</b></td>
<td>Q</td>
<td>R</td>
<td>S</td>
<td>T</td>
<td>U</td>
<td>V</td>
<td>W</td>
<td>X</td>
<td>Y</td>
<td>Z</td>
<td>(</td>
<td>)</td>
<td>:</td>
<td>;</td>
<td>[</td>
<td>]</td>
</tr>
<tr>
<td><b>A-</b></td>
<td>a</td>
<td>b</td>
<td>c</td>
<td>d</td>
<td>e</td>
<td>f</td>
<td>g</td>
<td>h</td>
<td>i</td>
<td>j</td>
<td>k</td>
<td>l</td>
<td>m</td>
<td>n</td>
<td>o</td>
<td>p</td>
</tr>
<tr>
<td><b>B-</b></td>
<td>q</td>
<td>r</td>
<td>s</td>
<td>t</td>
<td>u</td>
<td>v</td>
<td>w</td>
<td>x</td>
<td>y</td>
<td>z</td>
<td colspan="6"></td>
</tr>
<tr>
<td><b>C-<br>
D-</b></td>
<td colspan="16"><i>Unused</i></td>
</tr>
<tr>
<td><b>E-</b></td>
<td></td>
<td><sup>P</sup><sub>K</sub></td>
<td><sup>M</sup><sub>N</sub></td>
<td>–</td>
<td colspan="2"></td>
<td>?</td>
<td>!</td>
<td>.</td>
<td colspan="7"></td>
</tr>
<tr>
<td><b>F-</b></td>
<td></td>
<td>×</td>
<td></td>
<td>/</td>
<td>,</td>
<td></td>
<td>0</td>
<td>1</td>
<td>2</td>
<td>3</td>
<td>4</td>
<td>5</td>
<td>6</td>
<td>7</td>
<td>8</td>
<td>9</td>
</tr>
</tbody>
</table>

So I had to create a map/table containing all these characters in my JavaScript
code so I could translate the text in the save files to it's UTF-8 counterpart.
This was simple enough although it took longer than I liked (I was programming
this at around midnight at the time). Once complete it was simple matter of
reading the characters contained in the save file starting at the correct
offset to get the player's name and ending either when we encounter a
terminator character or when we get past the set length of the string
(this hearkened me back to learning C and how strings worked, and was just
as simple to program and understand).

Now I could read the player's name and any other string inside the save file
using a simple method call, so I added reading the Rival's name to the save
file viewer.

### Trainer ID and Other Number values

The next thing I decided to get working was reading the player’s Trainer ID.
This was simply stored as a number occupying two bytes starting in a specific
location in the save file. Because the save file had been loaded into memory
as a text string with one character per byte I needed to read the value of two
characters and convert them into the correct number. I did this using a simple
method shown below:

```javascript
function hex2int(offset, size) {
    var val = "";
    for(var i = 0; i < size; i ++) {
        var d = data.charCodeAt(offset + i).toString(16);
        if(d.length < 2) d = "0" + d; // append leading 0
        val += d;
    }
    return parseInt(val, 16);
}
```

(There may be a better way to do this but this worked well for me.)

This was then also used for all the other number values needed in the viewer,
including; the time played, number of an item, and Pokémon stats.

So now I had the ability to read and interpret most of the data in file I
cracked onto the more difficult parts of the save file data structure as well
as the slightly obscure ways it stored data.

### Show me the Money, and your Pokédex!

Money in the first generation of Pokémon games is not stored as a regular
number, but instead stored as a
[binary-coded decimal (BCD)](http://en.wikipedia.org/wiki/binary-coded_decimal),
so I had to write a routine to read the correct value from the 3 bytes that
represent each of the 6 digits.

I also had to write a routine to decode the Pokédex lists inside the save file
as well. These were coded in a very neat way, each Pokémon was represented by a
bit inside of 19 bytes (for a total of 152 values).
So all I did was output these as a long binary string.

### Items and Item Lists

There are two places items are stored in the first generation of Pokémon games;
the PC and the players bag. Each share the same basic structure called an Item
List, the only difference between them is their total capacity/length.

<table border="1">
<tbody>
<tr>
<th>Offset</th>
<th>Size</th>
<th>Contents</th>
</tr>
<tr>
<td>0x00</td>
<td>1</td>
<td>Count</td>
</tr>
<tr>
<td>0x01</td>
<td>2 * Capacity</td>
<td>Entries</td>
</tr>
<tr>
<td>… +0x00</td>
<td>1</td>
<td>Terminator</td>
</tr>
</tbody>
</table>

As you can see from this table (courtesy of bulbapedia again), the start of
each Item List contains 1 byte that tells you how many unique items the list
currently contains and another byte at the end of it used as a terminator.

Each item takes up 2 bytes in the table, the first tells you how many of that
item are present in the list, and the second is the item ID which is used to
determine what the item is called and what it does. As this is a save file
viewer the ability to discern what items you have in the save file are probably
quite relevant so I opted to create another table/map object similar to the
before mentioned character set that contained all the named objects in the game
and their corresponding IDs, as can be seen below.

```javascript
function getItemNameFromHexIndex(hex) {
    var itemMap = {
        0x00 : "Nothing",
        0x01 : "Master Ball",
        0x02 : "Ultra Ball",
        0x03 : "Great Ball",
        0x04 : "Poké Ball",
        0x05 : "Town Map",
        0x06 : "Bicycle",
        0x07 : "?????",
        0x08 : "Safari Ball",
        0x09 : "Pokédex",
        0x0A : "Moon Stone",
        0x0B : "Antidote",
        0x0C : "Burn Heal",
        0x0D : "Ice Heal",
        0x0E : "Awakening",
        0x0F : "Parlyz Heal",
        0x10 : "Full Restore",
        0x11 : "Max Potion",
        0x12 : "Hyper Potion",
        0x13 : "Super Potion",
        0x14 : "Potion",
        0x15 : "BoulderBadge",
        0x16 : "CascadeBadge",
        0x17 : "ThunderBadge",
        0x18 : "RainbowBadge",
        0x19 : "SoulBadge",
        0x1A : "MarshBadge",
        0x1B : "VolcanoBadge",
        0x1C : "EarthBadge",
        0x1D : "Escape Rope",
        0x1E : "Repel",
        0x1F : "Old Amber",
        0x20 : "Fire Stone",
        0x21 : "Thunderstone",
        0x22 : "Water Stone",
        0x23 : "HP Up",
        0x24 : "Protein",
        0x25 : "Iron",
        0x26 : "Carbos",
        0x27 : "Calcium",
        0x28 : "Rare Candy",
        0x29 : "Dome Fossil",
        0x2A : "Helix Fossil",
        0x2B : "Secret Key",
        0x2C : "?????",
        0x2D : "Bike Voucher",
        0x2E : "X Accuracy",
        0x2F : "Leaf Stone",
        0x30 : "Card Key",
        0x31 : "Nugget",
        0x32 : "PP Up",
        0x33 : "Poké Doll",
        0x34 : "Full Heal",
        0x35 : "Revive",
        0x36 : "Max Revive",
        0x37 : "Guard Spec.",
        0x38 : "Super Repel",
        0x39 : "Max Repel",
        0x3A : "Dire Hit",
        0x3B : "Coin",
        0x3C : "Fresh Water",
        0x3D : "Soda Pop",
        0x3E : "Lemonade",
        0x3F : "S.S. Ticket",
        0x40 : "Gold Teeth",
        0x41 : "X Attack",
        0x42 : "X Defend",
        0x43 : "X Speed",
        0x44 : "X Special",
        0x45 : "Coin Case",
        0x46 : "Oak's Parcel",
        0x47 : "Itemfinder",
        0x48 : "Silph Scope",
        0x49 : "Poké Flute",
        0x4A : "Lift Key",
        0x4B : "Exp. All",
        0x4C : "Old Rod",
        0x4D : "Good Rod",
        0x4E : "Super Rod",
        0x4F : "PP Up",
        0x50 : "Ether",
        0x51 : "Max Ether",
        0x52 : "Elixir",
        0x53 : "Max Elixir"
    };
    // Add all 5 of the HMs
    for(var i = 0; i < 5; i ++) {
        itemMap[0xC4+i] = "HM0" + (1+i);
    }
    // Add all 55 og the TMs
    for(i = 0; i < 55; i ++) {
        var num = (1+i);
        if(num < 10) num = "0" + num;
        itemMap[0xC9+i] = "TM" + num;
    }
    return itemMap[hex];
}
```

<p class="message">I was later given advice on how to improve this code's performance.</p>

That's a lot of items, especially TMs, luckily all the TM items were stored in
order so I could generate their entries automatically.

Armed with this function and the `hex2int` function previously shown I was able
to write a function that could parse an item list of any given length.

Now I had the ability to see a Trainer's name, Rival's name, Money, Pokédex
entries, and items in the trainers bag and PC, but something was missing...

### The Pokémon!

Each Pokémon the player owns is saved within the save file (obviously) and each
one in turn has many statistics associated with it that are also saved, making
them take up the majority of the file. They are also organized in special
separate lists. All of these factors consequently make them bit harder to parse.

There are in fact 14 Pokémon lists in the save file, 12 of which represent the
PC Boxes in game, with 1 also being used to store data on the current open PC
box and 1 being used for the Pokémon in the players party.

Pokémon Lists can vary in size and capacity but all follow the same structure:

<table border="1">
<tbody>
<tr>
<th>Offset</th>
<th>Size</th>
<th>Contents</th>
</tr>
<tr>
<td>0x0000</td>
<td>1</td>
<td>Count</td>
</tr>
<tr>
<td>0x0001</td>
<td>Capacity + 1</td>
<td>Species</td>
</tr>
<tr>
<td>… + 0x0000</td>
<td>Capacity * Size</td>
<td>Pokémon</td>
</tr>
<tr>
<td>… + 0x0000</td>
<td>Capacity * 11</td>
<td>OT Names</td>
</tr>
<tr>
<td>… + 0x0000</td>
<td>Capacity * 11</td>
<td>Names</td>
</tr>
</tbody>
</table>

Again this table comes from Bulbapedia. As you can see the first entry denotes
how many Pokémon are present in the given list (between 0 and the list's
capacity; this is either 6 or 20).

The second entry tells you the type of each Pokémon in the list based on an
index ID (you can see the list [here](http://bulbapedia.bulbagarden.net/wiki/List_of_Pok%C3%A9mon_by_index_number_%28Generation_I%29)),
so I had to create another map with the corresponding names in it (I wont show
it here since it would be very long). After doing this I was able to get out
the species of each Pokémon in a list (I started first with the party list),
but not the actual names/nicknames of each Pokémon in question.

The last set of entries in the table is a set of names, 1 for each Pokémon in
the list. These are stored in the same way as Item names and the trainer name,
as a text string using the correct character set. All Pokémon have an entry
here, even those without nicknames; their entries will be equal to their
species name (Note: Because of this if you nickname your Pokémon it's own
species name, in upper case, it will change upon evolving).

The OT Names list is simply a list of names referring to the original trainer
who caught the Pokémon.

So that leaves the actual Pokémon entries inside the list. These store the
actual Pokémon data structures and varies in length based on whether the list
represents a PC Box or the player's party.

For this I created a constructor that took in the starting offset for the
Pokémon in question and a boolean value that flagged it as a party member or
not. The difference between a party member Pokémon and PC Pokémon in terms of
storage was simply that the party member Pokémon stored extra values compared
to the PC Pokémon; this created a clever exploit in the first generation of
games known as the box trick, as these extra values were recalculated upon
removing a Pokémon from the PC and could be manipulated in certain ways.

Below is the code for the constructor method:

```javascript
function Pokemon(startOffset, isPartyMember) {
    this.index = hex2int(startOffset, 1);
    this.species = getSpeciesFromIndex(this.index); // derived from index
    this.currentHp = hex2int(startOffset + 0x01, 2);
    this.level = hex2int(startOffset + 0x03, 1);
    this.status = hex2int(startOffset + 0x04, 1);
    this.type1Index = hex2int(startOffset + 0x05, 1);
    this.type2Index = hex2int(startOffset + 0x06, 1);
    this.type1 = getPokemonType(this.type1Index);
    this.type2 = getPokemonType(this.type2Index);
    this.catchRate = hex2int(startOffset + 0x07, 1);
    this.move1Index = hex2int(startOffset + 0x08, 1);
    this.move2Index = hex2int(startOffset + 0x09, 1);
    this.move3Index = hex2int(startOffset + 0x0A, 1);
    this.move4Index = hex2int(startOffset + 0x0B, 1);
    this.ownerID = hex2int(startOffset + 0x0C, 2);
    this.exp = hex2int(startOffset + 0x0E, 3);
    this.hpEV = hex2int(startOffset + 0x11, 2);
    this.attackEV = hex2int(startOffset + 0x13, 2);
    this.defenseEV = hex2int(startOffset + 0x15, 2);
    this.speedEV = hex2int(startOffset + 0x17, 2);
    this.specialEV = hex2int(startOffset + 0x19, 2);
    this.IV = hex2int(startOffset + 0x1B, 2);
    this.move1PP = hex2int(startOffset + 0x1D, 1);
    this.move2PP = hex2int(startOffset + 0x1E, 1);
    this.move3PP = hex2int(startOffset + 0x1F, 1);
    this.move4PP = hex2int(startOffset + 0x20, 1);
    if(isPartyMember) {
        this.partyLevel = hex2int(startOffset + 0x21, 1);
        this.partyMaxHp = hex2int(startOffset + 0x22, 2);
        this.partyAttack = hex2int(startOffset + 0x24, 2);
        this.partyDefense = hex2int(startOffset + 0x26, 2);
        this.partySpeed = hex2int(startOffset + 0x28, 2);
        this.partySpecial = hex2int(startOffset + 0x2A, 2);
        this.isParty = true;
    }
    else {
        this.isParty = false;
    }
}
```

### And Beyond

That basically summarizes all the interesting parts of this project.
You can download the save file viewer from GitHub
[here](https://github.com/LyndonArmitage/HTML5PokemonSaveReader).
I did have a few interesting comments when I originally posted about it on
Reddit in 2013, one comment I really need to work on mentioned moving the
maps outside of the functions as it speeds up time considerably,
see
[http://jsperf.com/map-inside-vs-outside-of-function](http://jsperf.com/map-inside-vs-outside-of-function)
for details.

Upon getting some more free time I'd also like to see if I could get it
working in node.js and allow for uploads of sav files to work.

There is a live version of this viewer
[here]({{ "assets/html5-pokemon-save-reader/" | absolute_url }}).

