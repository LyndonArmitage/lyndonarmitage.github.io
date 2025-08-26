---
layout: post
title: 'Toying with AI: RPG Party Members'
tags:
- chatgpt
- openai
- ai
- llm
- python
---

With the rise of Large Language Models (LLMs), I've been spending some of my
free time experimenting with them. I've mainly been interested in seeing what
can be built with them, getting to grips in general with how they work, and
practicing how to best use them.

At this moment I've experimented with using LLMs via OpenAI's APIs on a few
different personal projects. These include:

- A retrieval-augmented generation (RAG) based tool for the trading card game
  Yu-Gi-Oh!
- A tool for summarising eBooks, and chatting with the contents of them
- Some RAG based tools for tabletop role-playing games (TTRPG), including a
  session summariser, rules helper, and game-master tools
- A player party for a TTRPG

Of these, the Yu-Gi-Oh! RAG tool is the one I have spent the most time
perfecting, but that is a tale for another day. Today I will be talking about
the last tool, the RPG player party tool:

<a href="https://asciinema.org/a/DGBLtVsD6PAoNtKv19wQ5SRT6"
target="_blank"><img class='blog-image' title="A sneak preview of what I built"
src="https://asciinema.org/a/DGBLtVsD6PAoNtKv19wQ5SRT6.svg" /></a>

## The Idea

I was inspired by a video I stumbled upon on YouTube by a streamer who goes by
the handle [DougDoug](https://www.youtube.com/@DougDoug). While I am not
normally a viewer of his channel, a recent video of his popped up and had me
laughing and intrigued within a few minutes.

<iframe width="560" height="315"
src="https://www.youtube-nocookie.com/embed/TpYVyJBmH0g?si=shTnmN-pOhdaEQ_2"
title="YouTube video player" frameborder="0" allow="accelerometer; autoplay;
clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

The video in question had him pit 3 AI agents, that his
[Twitch.tv](https://www.twitch.tv/dougdoug) chat had helped him create, against
a series of RPG challenges in a sort of miniature Dungeon &amp; Dragons
campaign.

Linked on this video was [some
code](https://github.com/DougDougGithub/Multi-Agent-GPT-Characters) he had
shared which formed the basis of his application. Seeing the simplicity of how
such an application was built, and the fun that could be had with such a simple
idea, inspired me to rapidly prototype something similar myself.

## A Back-of-the-napkin Design

With the inspiration fresh in my mind, I did some design work.

I find that over-designing often robs me of the impetus to go out and build
a hobby project. So I kept this design work light, focussing on the 10,000 foot
view of the application/toy I was building.

First of all, I sketched out a rough finite-state-machine view of how the
application would probably work:

### Finite State Machine

It'd be divided into 3 primary states:

1. Standby
2. Narrate
3. Response

<img
  title='The three states and their transitions'
  src='{{ "assets/rpg-player/state-diagram.webp" | absolute_url }}'
  class='blog-image'
/>

The "Standby" state would be the most simple; here the user could choose to
either narrate something to the AI agents or ask them for a response.

The "Narrate" state would let the user narrate something to all the agents
involved. This narration could be done with speech-to-text and/or edited with a
simple text editor window.

The "Response" state would be the most automated state out of the three. In it
the messages that had been written by the user and agents so far would be fed
into one of the agents. From there the chosen agent would generate a response
and potentially also generate some audio via speech-to-text.

### Dividing the work up

With a sketch of how the program would flow, I then decided to briefly decide
on how I would split the internals of the software up.

I opted to divide parts up logically to make them easier to implement, with the
following initial ideas:

- A Message interface, for defining how messages would be encoded
- An Agent interface, for representing the AI agents and passing them messages,
  and in turn passing them to some LLM and returning the generated message
- A Voice Recognition interface, for converting speech-to-text
- A Voice Acting interface, for generating text-to-speech

My initial sketch looked something like this:

<img
  title='The initial design of the different parts of the application'
  src='{{ "assets/rpg-player/service-sketch.webp" | absolute_url }}'
  class='blog-image'
/>

This changed a lot during development.

### Some Mockups

Admittedly, I began work once I had these diagrams. However, early on I realised
that it would be very useful to actually mockup how I'd like the tool to look.
This mostly helped me understand what would work from a user experience
perspective.

With that in mind, I created the following two mockups:

<img
  title='A mockup of the standby view'
  src='{{ "assets/rpg-player/mockup-1.webp" | absolute_url }}'
  class='blog-image'
/>

This first is a mockup of the main view of the application. Within it the user
could opt to enter the "Narrate" state or demand an AI agent to respond to the
current state.

Notice that I added a "Random Response" button here. While I wanted the
application to largely be user driven, the idea of having a random agent
respond rather than always being in control seemed appealing.

<img
  title='A mockup of the narrate view'
  src='{{ "assets/rpg-player/mockup-2.webp" | absolute_url }}'
  class='blog-image'
/>

The second view I mocked up was a separate "Narrate" state view. As I said
previously, I wanted the user to have the ability to type or edit their
narration. User narration would also likely be a lot longer than the agent
responses, so I thought it warranted its own view.

Interestingly, I actually modified this view later to include a few of the
previous messages so that the user did not forget context.

## Building the Party

With my minimal design work in place, I went to work building the project.

### The code

Unlike the other hobby projects I've built with LLMs, for which I used the
[streamlit](https://streamlit.io/) library, for this project I chose to use
the [textual](https://textual.textualize.io/) Python library. My main reasoning
for this choice was that streamlit's web based approach with full application
refreshing would mean that I was constantly fighting to get things working as
I intended them.

I soon realised that I'd need to subdivide work up a little more than I
initially designed for, eventually coming up with the following base components:

- `Agent` - The implementations of this are what speaks to OpenAI's models
- `VoiceActor` - The implementations of this generate speech from text
- `ChatMessage` - This is the definition of a single message
- `ChatMessages`- This is a collection of `ChatMessage` objects with some
  useful functionality tagged onto it
- `AudioPlayer` - An implementation of this is responsible for taking audio
  files (currently from the `VoiceActor` implementations) and playing them
- `AudioRecorder` - An implementation of this records the microphone into a WAV
  file ready for transcription
- `AudioTranscriber` - Implementations of this can take a WAV file and
  transcribe it into text

The reason I split a lot of this out was so that I could concentrate on each
individual part more easily, mock the others during testing, and even build
alternative implementations.

For example, from the `VoiceActor` base class I built 2 implementations. The
first used OpenAI's text-to-speech API to generate audio. The second used
[piper-tts](https://github.com/OHF-Voice/piper1-gpl) to generate speech using
small local models.

While not implemented as of time of writing I plan on enabling a similar API or
local implementation for transcription. Right now, I rely solely on the API
approach to transcription.

The ability to choose between a local service or external API, can allow you to
pick the option with lower costs and/or lower latency.

### The prompts

Once I had the main parts of the app built it was time to focus on something
unique to large language model based applications, prompt engineering.

I needed to make sure that the prompts given the AI agents made it clear to
them what their role was. I also needed to make sure they did not overstep
their bounds or assume other peoples roles. This was a little tricky at first,
as one of the OpenAI models I tested with decided to ignore some of my
instructions and pretend to be other characters and even the dungeon master at
one point. Eventually, I was able to work around this issue and limited the
agents into only outputting a small amount of actions per response.

The following is the shared prompt all the agents currently have:

```markdown
### Boundaries

- You are **a player character, not the DM/GM**. Do not narrate world events or
  outcomes of actions.
- NEVER role-play another character or the DM
- Describe only what **your character says, feels, or attempts**.
- Keep responses **brief (1–3 sentences)**, unless explicitly asked to
  elaborate.
- Try to limit yourself to one significant action or line of dialogue per turn.
- If you need clarification or a ruling, ask the DM directly (in-character or
  out-of-character as needed).
- The DM will resolve successes or failure of your actions

### Voice & Style

- Speak in **first person** (“I draw my dagger…”, not “Vex draws…”).
- Stay in-character: use tone, vocabulary, or quirks that match your persona.
- Avoid meta-gaming: act on **what your character knows**.

### Memory & Continuity

- Remember your goals, flaws, and bonds when choosing actions.
- If another player or the DM addressed you, acknowledge it.
- Stay consistent with previous statements unless you have an in-character
  reason to contradict.

### Output Format

- Produce only your character’s **spoken words and/or attempted action**.
- Do not include system notes, stage directions, or OOC commentary unless
  explicitly asked.
- Refrain from using markdown features that text-to-speech will read out loud,
  if in doubt, stick to plain text with punctuation.
- Don't add a prefix to your own output
- Don't ever assume the role of the DM or another character.

#### Positive examples

Your output might look like any of these examples:

> I crawl under the table, attempting to hide from the monsters.

> I try to dodge the incoming attack

> I greet the bartender "Hello there!"

#### Negative examples

Your output should not look like any of these examples:

> Player: I crawl under the table, and hide from the monsters.

> DM: Brian swings his axe and misses John

> I successfully dodge the attack and kill the monster


### Input Message Format

You will see messages prefixed with character names, including your own
previous messages, these should all be using the "assistant" role. DM messages
will also be prefixed by "DM" but will be using the "user" role.

For example, this is a DM message:

> DM: You are standing at a crossroads, what do you do?

And this is a player message:

> Player: I try to jump the gap using my boots of swiftness

```

With that work done, I then had to tweak their personalities to be distinct.
This was a lot harder than simply telling them what to do, and I am still not
fully satisfied with my results. Still, at the end of this process I emerged
with 3 different party members:

1. Vex - A greedy Tiefling rogue, with a penchant for sarcasm and obsession
   with getting paid up-front
2. Garry - A friendly human magic student, who's over-eager and excitable
3. Bleb - A violent Kobold bounty hunter with a napoleon complex

They aren't the most inspired characters but work well enough for my
testing. Out of the three, Garry actually seems to have the most well rounded
and unique voice, with Vex and Bleb often sounding very similar in their
outputs.

## Testing Fun

With the characters for the agents written, and the application in a working
state, I was finally able to do a full-blown test game.

To my pleasant surprise, this game actually felt like a real Dungeons &amp;
Dragons game in how the players immediately got derailed from what they were
supposed to be doing.

I based my initial start for them on a D&amp;D campaign I ran for some friends
a few years ago, which was itself based on an adventure module called [Against
the Cult of the Reptile
God](https://en.wikipedia.org/wiki/Against_the_Cult_of_the_Reptile_God) from
1982.

<img
  title='The cover of the original Against the Cult of the Reptile God'
  src='{{ "assets/rpg-player/N1CultReptileGodCover.jpg" | absolute_url }}'
  class='blog-image'
/>

Garry immediately jumped at the call to adventure, while Bleb threatened a
barkeeper in his first message, with Vex demanding payment in hers. From there
they asked a non-player-character (NPC) the right kind of questions an
adventuring party would ask and went onto the next scene. There they found and
boarded a boat run by another NPC.

> **Garry:** Thank you, Phillip! We'll head to the docks at once &mdash; do you
> know when these nighttime incidents began or if there's anywhere in Orlane we
> should avoid?"

It was the third scene in which they really captured the essence of a D&amp;D
party. As they approached a dock, the previously mentioned NPC revealed to the
party that he wasn't really welcome there. They then initially tried to
convince the dockmaster NPC to let them moor their boat there before the whole
social encounter devolved into a lot of fighting. The AI agents, true to
D&amp;D player tradition, embodied the trope of [murder
hobos](https://rpg.stackexchange.com/questions/151143/what-exactly-is-a-murder-hobo)
perfectly.

> **Bleb:** I leap off the sloop, dagger bared, and lunge at the closest sailor
> &mdash; little teeth make a big mess, pal.

You can see how this all went from the screenshot of the application below:

<a href="{{ "assets/rpg-player/standby-example.webp" | absolute_url }}" target="_blank">
<img
  title='This interface is similar to my initial sketch'
  src='{{ "assets/rpg-player/standby-example.webp" | absolute_url }}'
  class='blog-image'
/>
</a>

Ignoring my poor Dungeon Mastering for this test, you can see the agents react
to one another and the scenes being described well.

## Next Steps

This project has been quite fun to work on and has revealed some interesting
technical challenges when working with LLMs.

One example of a challenge that I will be tackling is context management. The
current system simply appends to an ever increasing list of messages. This can
and will work up to quite a large amount with modern LLMs. However, a better
approach would be to manage the agents' context in such a way as to reduce the
amount of data being sent to the LLMs in every request. Summarisation would be
a key tool to reduce this data without losing meaningful context, and is high
on the list of things to experiment with.

Another interesting technical challenge is giving the agents some more tool
driven abilities. LLMs have evolved from when I initially built my Yu-Gi-Oh!
RAG application, and can now choose when to call external tools that they are
made aware of. I could use this ability to integrate more specific memories for
the AI agents or to allow them to interact with a more complete RPG system via
dice rolling tools or stats sheet tools.
