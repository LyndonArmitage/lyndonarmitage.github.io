---
layout: post
title: Evaluating ChatGPT
tags:
- chatgpt
- openai
- ai
---

Unless you've been living under a rock, I am sure you are familiar with the
names [ChatGPT](https://chatgpt.com/) and [OpenAI](https://openai.com/). "AI"
or [LLMs](https://en.wikipedia.org/wiki/Large_language_model) (large language
models) have been all the rage as of late, and as a Lead Data Engineer I've
been tinkering with them for some time.

So I'd like to take you on a quick tour of my experiments with LLMs:

## Basic Chat Completions

First off, I tried using the chat completions UI that has since been deprecated
in favour of the ChatGPT interface. At the time it wasn't the best user
experience for what I wanted to do but it's ability to seemingly reason and
understand were quite astounding at first glance.

As experiments, I initially tested it with some odd prompts, such as getting it
to produce sonnets about fantasy characters or odd situations.

Later I tried to get it to use some context to produce interesting novel
result, for this I gave it some of the lore for a Dungeons & Dragons campaign I
was a player in. To my surprise it gave some interesting results, even with the
very limited context window and notes.

## Early ChatGPT Usage

After some time I used the ChatGPT interface and app for more general queries.
This again worked quite well. The chat interface really works well as a natural
interface.

During my initial usage I did notice some hallucinations but these have been
becoming rarer as the technology has developed.

I also found DALLE to initially be a very poor image generation tool, but this
has since changed drastically, as both my prompting skills have improved and as
the model has been improved.

## LLM in the IDE

I moved onto using OpenAI itself with my IDE, NeoVim. There's a great plugin
that I use often for general queries and some light "pair programming". I have
noticed that these LLMs aren't terrible at writing code but they aren't
groundbreaking engineers either. They sometimes make mistakes and invent APIs
that don't actually exist, or get stuck going in circles when asked for advice
with certain constraints.

I've yet to use it as a replacement for auto-complete, and don't really want
to. I have however used some of the code it has generated as the basis for some
experiments I have done using [pytorch](https://pytorch.org/) and
[tensorflow](https://www.tensorflow.org/). As well as the advice from ChatGPT
on these subjects as a starting point in my experiments.

## RAG Tools

With these usages out of the way, I tried to build some LLM powered tools,
specifically, RAG applications.

This might sound daunting but RAG is actually a very easy pattern. All you do
is supply context to the LLM based on the question being asked. The context
tends to be stored in some database and indexed with vector embeddings. These
embeddings are an encoding of the content that allows it to be compared to
other content in some meaningful way and are a key piece of "AI" research.

One RAG application I built was a helper for playing traditional table top RPGs
alone or assisting a game master. There exists many books and frameworks for
acting as an "oracle", these are often powered by random rolling of dice, but
ultimately rely on interpretation. LLMs seemed to be well suited to assist in
this area and remove some of the burden from the games master. This application
worked well in my testing with a superhero themed RPG. With some minimal
context on the setting, main character and some general rules, it was able to
generate a coherent narrative including some random challenges. It was even
able to generate some potential villains with coherent stats and appropriate
backstory.

## ChatGPT Enterprise

It will probably be of no surprise that ChatGPT is popular with my colleagues
as well. In fact, we are currently evaluating the enterprise version
internally.

We already successfully use OpenAI and DALLE to spice up our internal
presentations with appropriate images, as well as help with some coding tasks.
