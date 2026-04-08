---
layout: post
title: Simulating LLM Model Collapse
tags:
- ai
- llm
- openai
- chatgpt
- model collapse
---

In my previous post about LLM Model Collapse I went over what it is, why it's
bad and how to mitigate it. I cited a couple of papers related to it showing
that it isn't just an issue with Large Language Models, but is a problem with
any kind of generative model if they train on their own output. In this post
I'd like to demonstrate that fact using one of the simplest text generation
models I know of, the [Markov
Chain](https://en.wikipedia.org/wiki/Markov_chain) text generator.

To reiterate in short what I said previously; Model Collapse is the tendency
for a machine learning models output to degrade over multiple generations when
it is trained upon its own output.

A Markov Chain text generator, is a simple model that has been trained on some
corpus of text and can produce a next "token" based upon the previous state
with some random probability. With most Markov text generators, a "token" is
normally a word, often including any punctuation with it. The previous
state is normally restricted to the last *n* words, often called ngrams.
Most Markov text generators use the last 2 or 3 words as this tends to generate
somewhat coherent text, and these are called bigrams or trigrams respectively.

You can visualise the Markov Chain text generator as a graph with many
subgraphs in it. The ngrams are nodes leading to the next potential tokens with
different weights based upon frequency in the training data.

Markov text generation can produce some interesting results, however they're
often incoherent as it is literally just parroting previously seen tokens.
Interestingly, if you squint, you can view large language models as being quite
similar, in fact, their picking of next tokens is somewhat stochastic in a
similar way to Markov chains. However, they're obviously a lot more
sophisticated, especially when it comes to tokens and trained on absurdly
larger amounts of data. Still, I would bet that training a Markov text model on
similar scales could produce some interesting and more coherent outputs. If you
spent some time doing some slightly more sophisticated tokenisation (e.g.
treating punctuation and white-space as their own singular tokens), I expect
the results would be surprisingly sophisticated.

Let's explain the experiment and hypothesis:

> A Markov Chain text generator trained on its own input will degenerate into a
> model collapse in a similar way to large language models.

To test this I will be using a fixed size corpus as the starting point and
generation 0 training data.

After training, I will generate a similar sized output to the original training
data using the model and train the subsequent generation on said generated
data. I will do this for multiple generations.

From each generation I will extract some statistics including:

- Average number of out connections from ngrams in the generation
- Count of unique ngrams in each generation
- Unique word frequencies in the training data for each generation

I expect that the average number of outbound connections from ngrams along with
their unique count will reduce every generation as information is lost. This is
the model collapsing. I also expect the unique word frequencies to start to
skew towards the more common words from the original corpus and for the overall
unique count of words to reduce.

I'll be using trigrams and a small corpus for my initial experiment. The corpus
will be a short story by H.P. Lovecraft that is in the public domain. I've
cleaned the text to remove lots of extra spacing but kept in all punctuation.

