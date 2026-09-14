---
layout: post
title: Creating a simple YouTube Summariser
tags:
- ai
- llm
- openai
- programming
- coding
- youtube
- python
---

I this post I aim to quickly go over how I built my own simple YouTube video
summarising tool using a combination of a few tools including a call to a
large-language model.

Many famous programmers inside and outside the open-source community advocate
for building your own tools. In fact it's one of the UNIX traditions to build
small, focused tools and make them interoperable so that users can combine them
together to build more tools.

I think that building your own tools is a great way to learn how something
works in theory and then see how that theory plays out in practice. In fact I
held a membership with [CodeCrafters](https://codecrafters.io/) for a year or
so and practiced building my own version of Redis.

Normally when building your own tool it helps to start with a simple goal or
problem. If you have too wide a scope you'll struggle to get everything done
and you might abandon the project. This isn't terrible in itself: you're sure
to learn a lot while building such a thing, but if you want a useful tool at
the end, it helps to put limits on what you want to build from the start.

In my case, I wanted a simple tool that could summarise a YouTube video into
Markdown that I could save into my notes or use to decide if I wanted to watch
the whole video.

You might note that there already exists tools like
[YouTubeSummary.com](https://youtubesummary.com/) that satisfy a lot of my
requirements. In such a situation, you can use these existing tools as
inspiration. Linus Torvald was inspired by
[BitKeeper](https://www.bitkeeper.org/) when he created
[Git](https://git-scm.com/), but he wanted something free with specific
features that did not exist in the alternatives at that time. In fact, with Git
Linus took some of the existing systems of examples of what he wanted to avoid.

In my case, YouTubeSummary does a good job at 80% of what I want, but it
doesn't output Markdown, and I am not in control of how it decides to summarise
videos.

Given that I've done a lot of work in Python in recent years, and how simple I
envisioned the summary generator to be, I opted to use it as my language of
choice for this tool.

In my experience, if you don't focus on code quality and good project hygiene
from the start, it can become a nightmare later. So I started out by installing
some linting and code quality tools;
[basedpyright](https://docs.basedpyright.com/latest/) for type-checking,
[ruff](https://docs.astral.sh/ruff/) for linting, and
[black](https://black.readthedocs.io/en/stable/) for formatting. Alongside
these I also added in [pytest](https://docs.pytest.org/en/stable/), although
for such a small and personal project I did not implement many unit-tests. That
is one of the perks of building your own tools, you can decide upon how you
develop and what tools you use when building the new tool. You'll also suffer
for all of these decisions if/when you decide to share your tool with the
world!

I've taken to using [uv](https://docs.astral.sh/uv/) as my project manager for
python projects, which made installing the above tools a breeze and later made
making my tool available on my system easy thanks to
[uv tool install](https://docs.astral.sh/uv/concepts/tools/).

With my mostly empty development project setup, I then took a step back and
made notes on what I wanted to build. I've been trying out various ways to take
notes have settled on using a tool called
[zk](https://zk-org.github.io/zk/index.html) which is built upon the idea of
keeping notes in a plain-text
[Zettelkasten](https://zettelkasten.de/introduction/); something like a
personal-wiki, similar to [Obsidian](https://obsidian.md/). So I took some of
the raw ideas I had and collated them into their own page and iterated over
them.

I've used a Python based tool for downloading YouTube videos for a while now
called [yt-dlp](https://github.com/yt-dlp/yt-dlp). It includes a feature for
downloading subtitles. Subtitles are what YouTubeSummary and other tools tend
to use for generating summaries. So I took a note that `yt-dlp` may be a useful
project/library to use in my tool. From this note, and an exploration of the
subtitles that I had downloaded, I found that they followed a specific format
called [WebVTT](https://www.w3.org/TR/webvtt1/). Investigating this led me
to some more Python libraries that could more easily parse these files to plain
text.

My initial plan for the tool became the following:

1. Parse a YouTube video URL
2. Use `yt-dlp` to download the subtitles
3. Use a library like [webvtt-py](https://webvtt-py.readthedocs.io/en/latest/)
   to parse the subtitles into plain text.
4. Feed the subtitles along with a prompt to an AI model like OpenAI's
   `gpt-5.6` to generate a summary
5. Format the summary as Markdown
6. Print the summary out to the terminal

In my notes, I even wrote the words "Nice and simple." Unfortunately, it was
neither. At least not right away.

I initially thought the complicated part would be the converting of the
subtitles to simple plain-text. This was due to how `yt-dlp` wrote out the
`webvtt` files, which included keeping the same lines of text in multiple
segments.

However, it turns out that `yt-dlp` isn't really built to be used
programmatically by other Python code. My attempts to do so, worked, to an
extent but, as my type-checker and linting tools kept reminding me, it was
suboptimal.

So after some time I reopened my browser and found that there already existed
libraries in python for extracting subtitles from YouTube.
The purpose-built library I settled on was
[youtube-transcript-api](https://pypi.org/project/youtube-transcript-api/).
Which also made converting the subtitle parts into coherent text even easier,
as it did not try to align to the `webvtt` format.

Summarising text is something large-language models are already good at, so
that still remained simple. With a few lines of a simple prompt, and a call to
a Markdown formatted I was able to have my summariser working!

Now in theory, that could be the end of the tool. It can get subtitle
transcripts and feed them to an LLM and output the results. And when testing
said results were serviceable. However, I wanted this tool to be easy to use.

So I polished the interface you use to call the tool. Specifically I switched
to using the [tyro](https://brentyi.github.io/tyro/) CLI library. I even still
used `yt-dlp` to get some extra video metadata that I thought might help
summarise the video:

- I made sure to closely document the inputs
- Added the ability to save both the transcripts and summaries to files directly from the
  tool
- Allowed you to inject the video ID and title into file names if desired
- Gave the option to add additional prompts to the AI model call, in case you
  had some specific context to give to the summary tool
- Added a toggle to only use non-generated captions
- Added tags and metadata that could be added to a Markdown front matter

Up to this point, the project was mostly contained in a single Python file. So
I refactored the project to make it easier to reason about how things were
implemented. Leaving your projects in a reasonable state before you think of
them as finished can really help if you ever need to go back and modify them
down the line, since you will have forgotten all the contextual information.

And with all that work, I had created a tool that essentially replicated some
of the features of other YouTube summary generators but was available to me
within my terminal workflow and suited my needs.

I now reach for this tool as opposed to other online tools. With some personal
defaults, I can keep a record of videos I have watched and found interesting.
Alongside my own notes, the video summary lets me quickly reference an idea
without having to watch a video again, and I am less beholden on some
third-party.
