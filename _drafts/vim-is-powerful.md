---
layout: post
title: vim is Powerful
tags:
- linux
- vim
- terminal
---

The text editor vim is really quite powerful! I am always surprised by how
much so!

I've been using vim for almost a decade now but not really as my primary
editor. I've gone through phases of customising it with plugins and custom
config settings. In fact I am currently storing my config files on my
[Github](https://github.com/LyndonArmitage/init.vim).

Since most of my career has been spent using Java and JVM based programming
languages I have spent much time using the Jetbrains IDEs, specifically
IntelliJ but over the years I have been more and more drawn to using vim for
non programming tasks, writing files or viewing other programming language
sources. It is truly an incredibly versatile editor!

Recently I was blown away by some of the auto-formatting functionality built
into vim. I write these blog posts in markdown using vim and try to stick to a
nice format that a linting tool recommends. That means keeping text to about 80
columns long, and markdown requires you to separate paragraphs with 2 new
lines. Not too long ago I was manually making sure that these files fit these
criteria, then I enabled automatic line breaking to vim and instantly did not
have to worry about lines going over the 80 column limit I had set.  
This was great! But often I edit these posts a little rather than them being
straight mind dumps and the automatic line breaking doesn't always cope with
this, especially if I am rephrasing and moving parts of text around. This is
where the formatting commands for paragraphs come in!

I tooted on Fosstodon my amazement at the commands `gwip` and `gqip` both of
which re-flow the paragraph under your cursor. This works on indented
paragraphs too like quotes!

Being impressed I wondered if you could apply such a command to a whole
document. I spent a short time last year practicing my writing in LaTex and
wanted to see if I could reformat some of it, I also have some books from
Project Gutenberg downloaded as text files that I could experiment on with vim.

After some thought on doing this with vim macros, another feature I've only
recently really started using I was pointed at the commands `ggvGgq` that would
just apply formatting to a whole file! Breaking it down
[@splatt9990](https://fosstodon.org/web/statuses/105979861702188219) on
Fosstodon explained that `gg` goes to the top of the document, `v` then enters
visual mode, then `G` goes to the bottom of the document and finally `gq`
formats your selection.

Another feature I found last year was the ability to interact with the system
clipboards. Even though vim is primarily a terminal editor you can access the
system clipboards and paste with the command `"+p` and copy to it with `"+y`.
That unlocked a whole load of possibilities to take data that I am having
trouble formatting in another application and put it into vim for me to apply
macros and other formatting too.

And that's the beauty of vim and why it's so powerful, there's so many simple
commands and tools within it that can be combined together. Initially the
concepts might be confusing and you won't remember everything but if you
actually try to use such features it becomes clear why so many people use it!

I strongly recommend people give it a go, load up the vimtutor or watch a short
video on it and try it out. There's even binaries for
[Windows](https://www.vim.org/download.php#pc). Once you start using it you
might be shocked by how lackluster and simple other editors are! Just remember
how to quit `:qw` or `:q!` ;)
