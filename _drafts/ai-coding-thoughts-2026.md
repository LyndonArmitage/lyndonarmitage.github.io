---
layout: post
title: AI Coding Thoughts 2026
tags:
- chatgpt
- ai
- llm
- coding
- programming
- thoughts
---

Recently a video popped up in my feed about a developer's experience of coding
with AI and why they were done with it. I found it interesting and began
writing a comment to respond to it, only to realise it became rather long. So I
thought I'd expand it into a blog post about my thoughts on coding with AI,
LLM-based agents etc.

First of all, the video in question was one from the YouTube channel [Brett
Codes](https://www.youtube.com/@brettcodes) titled "I'm done coding with AI":

<iframe width="560" height="315"
src="https://www.youtube.com/embed/2ZU3j4GQ4K8?si=J15cEyAJnRn011Rr"
title="YouTube video player" frameborder="0" allow="accelerometer; autoplay;
clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

I encourage you to watch it first to put my thoughts in context. I've also used
a tool to [summarise the
video](https://youtubesummary.com/summary/2ZU3j4GQ4K8), but these summaries are
never as good as watching the whole thing.

First of all, his early experiences with the Copilot's function autocomplete
partially mirrors my own experience with some AI-based tools. They can be
distracting and not useful when you're in a flow state. We had mostly learnt
this lesson with auto correction software for text, but in recent years it
seems to have been unlearned.

Previously, it was normal to see a red or green underline in your editor. You'd
later correct the mistake, or go back quickly and correct it as you wrote. We
then switched to autocorrect fixing common typos, which works well most of the
time, when it is correcting simple things, but can be annoying when it
overreaches. Now we have editors suggesting multiple words and phrases, robbing
you of the thought process that goes into writing and/or biasing you towards
more sterile language. I know in recent emails I have sent that I got very
annoyed at the suggestion of how I should sign off. I will choose when I am
being sincere, thankful or curt thanks!

Brett also describes an incident when debugging an issue in 2022/2023 related
to an AI hallucinated software dependency version. I've experienced something
similar even going into 2026. Large Language Model training currently cannot
stop such hallucinations, and it is a fundamental issue with the architecture
they're built on. Much to the chagrin of AI evangelists, who've claimed that
hallucinations no longer occur.

I am sure hallucinations happen less frequently than before, thanks to better
tooling providing more live context, but that doesn't prevent it. This is a
main reason why you should always be sceptical of the output of AI. It can
confidently "cite" sources which, when you come to read them, don't actually
say what the AI produced text claims they say. The issue the evangelists have
is something akin to [Gell-Mann
Amnesia](https://en.wiktionary.org/wiki/Gell-Mann_Amnesia_effect), they
believe the bluster from the AI because of the source and their own limited
knowledge of the subject.

With all that said, it doesn't mean AI isn't a useful tool. For example,
summarising documents you've written or read is a task that a large language
model is well suited to do for you, since you know the contents. I know I've
had limited successes with them summarising meeting transcripts, provided I
either prompt it with my own notes or steer it to the items of importance.

Brett mentions a health incident where he erroneously went to the emergency
department based on the advice of a chatbot. While I hope he is well, this
isn't that dissimilar from people heading to see doctors after Googling their
symptoms or looking them up on WebMD. It was definitely a good wake-up call on
how he should doubt AI-generated output and always remember that he isn't
actually communicating with a reasoning being when engaging with a chatbot.
Again, AI isn't completely useless here. Provided you give it enough context
and take what it says with a grain of salt, it can help narrow down a
potential ailment. But you have to always remember that there's no substitute
for a medical doctor's training and experience.

AI chatbots, more often than not, act more like a mirror when you present them
with emotional language or leading arguments/phrases. This isn't that
surprising when you understand how the raw model works after pre-training.
Next-token prediction will naturally try to continue on the given context; that's
fundamentally what it's designed to do. Even with post-training, this behaviour
still exists, it's just mixed in with the question and answers format.

He also mentions the pressure to use AI. This is something I think most people
in a lot of industries can sympathise with, and I think he does identify one of
the key reasons why: pressure from higher-ups who've bought into the hype from
AI providers.

In the second half of his video, he describes his experiences using AI coding
tools and agents. The existential dread, building becoming review, and distance
from the creative process reducing care, are all things I can sympathise with.
Again, I recommend you watch the video as I won't to retread all his points in
detail.

The feelings of dread and purposelessness are highly relatable, and I think
stem a lot from the hype and discussions around AI replacing creative work like
software engineering. We're however many years into the "AI will replace coders
in 6 months" era, and that constant uncertainty is sure to play on anyone's
mind, even if they don't fully believe it. We've seen claims around 100x
improvements in output, people proclaiming themselves to be productivity
wizards with 5+ Anthropic subscriptions, "autonomous" agents hacking websites,
and dozens of security vulnerabilities revealed by AI models. It's enough to
make you want to cut your internet lines and live in the woods.

The things we need to remember about all this are threefold:

1. There's a lot of marketing hype from these AI companies, chip manufacturers
   and infrastructure providers. They have clear monetary incentives to get you
   on board their hype-train, either in support or in opposition, either way
   you're thinking about them and/or spending money on them.
2. We've not actually seen these supposed gains of AI. At least not the
   outrageous claims that are thrown about. There's been no explosion in the
   number of successful businesses built off of the back of AI. Sure, it's
   being used successfully to some extent, but the jury is still largely out on
   the effectiveness and usefulness.
3. Anything with the monumental spend that AI has had in the last few years,
   would have produced some of the results we are seeing. Take the security
   vulnerabilities found, had the same amount of money and effort been spent on
   security hackers and research, it's likely that we'd have seen a similar
   amount of found vulnerabilities.

I'm sure I could make other points too, but the above three are hopefully
enough to fight off the dread and ennui.

Brett's other concerns around the work becoming tedious, the impact on caring,
learning and quality all stem from what could be called misuse of AI, in my
opinion. Not Brett's misuse itself, but the wider industry and attitudes
towards it in general.

Large language model powered AI is still a tool at the end of the day. I am
often reminded that "a bad workman blames his tools," normally when I am
yelling at my computer about a mistake that is inevitably revealed to be my
own!

We should be using AI to automate the parts we don't like out of process, not
letting it take over the things we enjoy. I know an early experimentation with
AI generated code in my RPG Party Members project yielded workable code in one
of the interfaces, but it ended up being code I did not wholly understand. It
robbed me of the pleasure of learning how to do something myself, while
implementing something close enough to what I was imagining.

I can and do use LLM tools like Codex to generate unit tests for code I have
written. The generated tests run and essentially work to ensure the current
functionality persists over time. This is similar to how you write tests in
non test-driven development. I can still write said tests myself, and sometimes
do, at least initially, but they're tedious and not the area I want to spend
time and focus on.

Of course, with my generated tests I have to understand that the generated code
is neither infallible or revolutionary. More importantly, I need to review
them to make sure they're valid.

Has the AI removed some benefits and increased my distance from the code?
Probably. The issue with getting a coding agent to work for you is that it
removes you from the coding feedback loop. Every moment you are coding, you are
making micro-level decisions, you're solving problems, and evolving your
understanding of the wider whole of the software being built. Even when writing
tests this is true; I might spot a logic error, typo or other nonfunctional
issue for example. These are things that AI generated code just breezes through
or makes assumptions on your behalf about.

This micro-decision problem is magnified when you ask a coding agent to do
non-simple tasks. Suddenly, you're no longer involved beyond the occasional
prompt. You're understanding of the software doesn't become much deeper than
the high level design, and if you want it to, you then fall into the AI code
review trap. Either you review every statement and internalise it, or you rely
on the AI to have been correct.

When reviewing code written by a fellow human you can rely on them since they
have an ego, a level of experience, competence, their own style, and an
internal model of the software in their mind. You know that Bob writes code a
certain way, has made certain mistakes in their past, and is less likely to
make them again, so you can breeze through certain parts of a code review as a
result. A coding agent has no ego, making a mistake to it doesn't cause it
anxiety, it doesn't bear the risks, it can simply vomit out code that is
statistically "good enough".

So what I am saying is, we have misaligned how we use these AI tools to an
extent and that is causing a lot of the friction and woes Brett talks about in
his video. If any higher-ups in business are reading this, I implore you to not
mandate specifically how your teams use AI. Instead, you should empower them to
use it within limits, remind them to use to smooth over the parts of their work
that are more mechanical and frustrating. Don't tie metrics to its direct use,
that'll create perverse incentives and more than likely run up your bill while
making some people miserable, and risk deskilling your teams, forcing reliance
on the AI providers.
