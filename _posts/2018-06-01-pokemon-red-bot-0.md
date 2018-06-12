---
layout: post
title: Pokémon Red Bot Part 0
---

For quite some time I have had the idea of making a simple bot that could play 
one of my favourite (old) games; Pokémon Red for the Nintendo GameBoy.

<img alt='Pokémon Red Title Screen' src='{{ "assets/pokemon/pokemon-red-title.png" | absolute_url }}' class='blog-image'>

Given that Pokémon Red and Blue were released in 1996 in Japan, (1999 here in 
the UK) they couldn't be too hard to program a bot for right?  
Wrong. Pokémon Red is a role playing game (RPG), and a well made one at that, 
which means it is relatively complex as a result. 

How complex? Well you can actually look at a dissembled and annotated version 
of the assembly code that makes up the game on 
[GitHub](https://github.com/pret/pokered) to get an idea. Sufficed to say, 
there's a lot of code there! However it's a fun game that I spent many days 
playing back when I was younger so let's give it a go!

# Quick Overview of the game

Before I propose my approach to making a bot for this game I am quickly going to 
go over some of the mechanics of the game; this won't be a super in-depth 
overview of the game, for that I suggest reading the game's manual (remember 
those?), watching a playthrough online or playing the game yourself (there's 
always copies for sale online, or you can emulate it on your computer).

There are 2 main modes of play in Pokémon Red/Blue; walking around the 
over-world and battling Pokémon/Trainers:

## The Over-World

<img alt='Pallet Town' src='{{ "assets/pokemon/overworld-pallet-town.png" | absolute_url }}' class='blog-image'>

The over-world itself is quite expansive with 10 towns, dozens of routes and, 
many more areas to explore. Each of these areas is made up of a gridded map with
both static and mobile objects that can be collided with.

<img alt='Overworld Map' src='{{ "assets/pokemon/overworld-map.png" | absolute_url }}' class='blog-image'>

The player explores these areas by moving around using the directional buttons
and A button to interactive with objects. There are also special moves (HMs) 
that become available as you progress opening up access to before closed off 
areas.

<img alt='Choppable Tree' src='{{ "assets/pokemon/overworld-tree.png" | absolute_url }}' class='blog-image'>

Building a bot that can automatically run through the game and deal with these 
obstacles could prove to be quite a challenge on it's own but I haven't 
mentioned the fact that battles are triggered whilst in the over-world forcing 
you to fight wild Pokémon or other trainer's Pokémon!

<iframe src='https://gfycat.com/ifr/TornDeepBactrian' frameborder='0' scrolling='no' width='160' height='144' allowfullscreen class='blog-image'></iframe>

## Battles

<img alt='Wild Pidgey Appeared!' src='{{ "assets/pokemon/wild-pidgey.png" | absolute_url }}' class='blog-image'>

Battles commence with a wipe to black animation (that differs depending upon if 
it's a wild Pokémon, Trainer or Gym Leader).

<iframe src='https://gfycat.com/ifr/CanineSilkyEgg' frameborder='0' scrolling='no' width='160' height='144' allowfullscreen class='blog-image'></iframe>

Then you are presented with the opponent Pokémon, your own Pokémon and 4 
options:

<img alt='Battle Menu' src='{{ "assets/pokemon/battle-menu.png" | absolute_url }}' class='blog-image'>

These are mostly self explanatory:

<div style="margin-left: auto;margin-right: auto;">
<img alt='FIGHT Menu' src='{{ "assets/pokemon/battle-attack-menu.png" | absolute_url }}' style="display: inline;">
<img alt='PkMn Menu' src='{{ "assets/pokemon/battle-switch-menu.png" | absolute_url }}' style="display: inline;">
<img alt='ITEM Menu' src='{{ "assets/pokemon/battle-item-menu.png" | absolute_url }}' style="display: inline;">
<img alt='RUN AWAY' src='{{ "assets/pokemon/battle-escape.png" | absolute_url }}' style="display: inline;">
</div>

* FIGHT - Takes you to a menu for choosing an attack for your Pokémon
* PkMn - Takes you to a menu for switching out to a different Pokémon
* ITEM - Takes you to a menu for using items on your Pokémon or the opponent 
  Pokémon (something you can't do in a trainer battle)
* RUN - Lets you attempt to escape from the battle (something you can't do 
  against a trainer)

I'll go into a little more detail on combat and statistics that your Pokémon 
have:

### Stats

<img alt='Pokémon Stats' src='{{ "assets/pokemon/pokemon-stats.png" | absolute_url }}' class='blog-image'>

Every Pokémon has a 2 types and a bunch of statistics.
The main stats are:

* ATTACK - Effects how much damage attacks do
* DEFENSE - Effects how much damage is mitigated from attacks
* SPEED - Effects who goes first and dodge chance
* SPECIAL - Effects damage AND resistance to special type attacks (in subsequent 
  games this was split into 2 stats)
* HP - Hit Points, the amount of damage a Pokémon can take before fainting

You'll notice in that screenshot there is also a STATUS, IDNo and, OT.

#### Status

In Pokémon Red/Blue there are several states a Pokémon can be in that can be 
divided between "non-volatile" and "volatile":

"Non-Volatile" states are the most common and last between battles they are:

* Burn
* Freeze
* Paralysis
* Poison
* Sleep

"Volatile" states include special statuses that only last during a battle like
confusion, being in a bind, leech-seeded etc.

For more information on these statuses see 
[this excellent article on Bulbapedia](https://bulbapedia.bulbagarden.net/wiki/Status_condition).

#### IDNo & OT

The IDNo and OT pieces of data that identify who first caught this Pokémon. 
With IDNo being a generated "unique" ID for the player and OT standing for 
Orignal Trainer and being the name of the player who caught the Pokémon.

#### Experience and Levels

Pokémon also gain experience and level-up during the course of the game. This 
increases their stats, allows them to learn moves and sometimes evolve into new
Pokémon.  
Normally experience is gained as a result of combat but some items can do this 
too, notably the Rare Candy.

This is a big topic but the essentials are higher level = stronger Pokémon. 
Again for more details, including formulae for how leveling works you can read 
[another article on Bulbapedia](https://bulbapedia.bulbagarden.net/wiki/Experience).

<img alt='EXP Chart' src='{{ "assets/pokemon/ExpToNextLevel.png" | absolute_url }}' class='blog-image'>

### FIGHT

The FIGHT menu lets you choose from the attacks your Pokémon knows.

Your Pokémon is limited to having up to 4 attacks.

Each of these attacks has a number of Power Points (PP) these are the amount
of times an attack can be used before you need to restore the PP using an item 
or by visiting a Pokémon Centre to heal your Pokémon.

Each attack also has a type that is used to determine bonus damage against 
Pokémon of certain types e.g. FIRE is effective against GRASS.

You can see your Pokémon's type by looking in the Pokémon menu from the 
over-world screen or the PkMn menu from the Battle screen.

There's quite a lot of types in Pokémon Red/Blue and a chart for showing the 
advantages can be found 
[here](https://bulbapedia.bulbagarden.net/wiki/Type/Type_chart#Generation_I) 
(again on Bulbapedia).

Not all attacks do damage, some just effect the stats of yours or the opponent
Pokémon temporarily during battle. For example the GROWL attack will reduce the 
enemies ATTACK stat. Some also inflict status effects as mentioned previously.

Below is an example of a battle (in which I almost lose):

<iframe src='https://gfycat.com/ifr/PalatableShadyAmericancrow' frameborder='0' scrolling='no' width='160' height='144' allowfullscreen class='blog-image'></iframe>

# Building a Bot

Given the complexity of the game it's clear that I need to divide my efforts up 
into parts. But before all that I'll need a way of running the game and bot, 
that's where an emulator comes in!

## A GameBoy Emulator

<img alt='A GameBoy' src='{{ "assets/pokemon/Gameboy-Vector.jpg" | absolute_url }}' class='blog-image'>

There's a lot emulators out there for the GameBoy and GameBoy Color. At one 
point I considered, and started to write my own. But this is an arduous and time 
consuming task in it's own right.

Instead of writing my own I have settled on the idea of augmenting an existing
Open-Source GameBoy emulator to serve as the engine for running the actual 
Pokémon Red game. A 
[quick search of GitHub](https://github.com/search?q=gameboy+emulator) reveals 
there to be quite a lot of GameBoy emulators.  
In an effort to limit these results and choose something I can get started with
quickly I limited this list to those written in Java and found the first one to 
be an incredibly popular [repository](https://github.com/trekawek/coffee-gb) 
that was mentioned in a 
[good blog post in February 2017](http://blog.rekawek.eu/2017/02/09/coffee-gb/) 
and also based on a talk entitled: 
[The Ultimate Game Boy Talk](https://www.youtube.com/watch?v=HyzD8pNlpwI) which
is a fantastic talk on the architecture behind the GameBoy.  
This emulator, called [Coffee GB](https://github.com/trekawek/coffee-gb), whilst
sparsely commented is structured incredibly well, very easy to follow and, 
hopefully easy to integrate and extend.

Previously when playing and experimenting with emulating the GameBoy I have run 
into several other useful emulators (which I have used to provide screenshots 
and animations in this post), including Visual Boy Advance and 
[BGB](http://bgb.bircd.org/). The former having many Open-Source variations, and 
the latter having incredibly good debugging features, which I am sure will come 
in handy...

## The Game itself

There are myriad of websites where you can find ROM dumps of original GameBoy 
games although I do not condone this act unless you own the original game, you 
can also dump your own cartridges if you're crafty enough by using an Arduino or 
Raspberry Pi and some electronics sorcery. Luckily I do own the original 
cartridge and have access to a ROM dump that matches my copy.

## Initial Goals & Planning

Now that I have the game ROM and something to develop with I can go back to
planning the goals of this project and stages to achieve them:

My initial goals will be to:

1. Build a simple API that will allow you to control the player's avatar in the 
   over-world
2. Build a simple API that let's you get information on what is present in the 
   world around the player's avatar

Both goals complement each other, and with them in place I can build upon them 
later to create a more fully fledged bot.

In order to achieve both these goals I will need the following:

* A way of sending input to the game
* A way of interpreting the over-world environment

The former should be relatively easy to do as most emulators have hooks to do 
such things since you need to pass control from the user to the emulator.

The latter will be harder as it involves reading the memory (RAM) being emulated
filtering and, converting it into usable information.  
Luckily a lot of work has been done in this field as Pokémon is a very popular 
game amongst ROM Hackers; people who essentially mod ROMs of old games to create
new and modified content.  
[Romhacking.net](http://www.romhacking.net/) is a site dedicated to this hobby 
and has an extensive wiki that includes a 
[RAM Map](http://datacrystal.romhacking.net/wiki/Pokémon_Red/Blue:RAM_map) of
Pokémon Red/Blue (with much of the data gleaned from the dissembled source 
code). Something that may also prove useful is the fact that there are many 
tools released for ROM Hacking Pokémon Red/Blue such as map editors that read 
the hardcoded layout of the maps in the game.

That's all for this post, stay tuned for the next one where I will have made 
some progress on this project!
