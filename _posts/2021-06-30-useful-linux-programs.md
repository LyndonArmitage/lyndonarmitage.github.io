---
layout: post
title: Useful Linux Programs
tags:
- linux
- programming
- command line
- terminal
date: 2021-06-30 15:51 +0100
---
Having been using Linux exclusively as my operating system for development for
quite some time now I thought it was time to catalog some of the useful
commands and programs I use in the terminal on an almost daily basis.

I am not an expert user by any stretch of the imagination so some of my
examples might not be the most efficient or even appropriate but they work well
for me, feel free to shoot me an email or leave a comment where you see this
article linked with more suggestions.

Everyone who uses some flavour of Linux (or Unix) knows the standard `cd`, `ls`
and `cat` programs. I use these a lot but it is worth mentioning some tips
around them.

## cd

`cd` changes the directory you are in. You can give it a relative or absolute
path e.g.

```sh
cd /tmp/foo
cd foo/bar
cd ../foo
cd ../../foo
cd ...
```

`.` Stands for this directory, `..` stands for up a directory, and `...` stands
for up 2 directories. Very useful when you know where you are and need to
navigate around.

You can also use just `cd` on it's own to return to your home directory.

For something a bit more advanced you can use environment variables with `cd`
like so:

```sh
# This is the equivalent to just cd on it's own
cd $HOME
# But this saves a little typing
cd $HOME/.config/
cd $JAVA_HOME
```

## ls

`ls` lists the current directory you are in.

Common variations of it are:

```sh
# To list things in a list format
ls -l
# To list all files even hidden ones
ls -a
# To list all files in a list format with human readable text
ls -alh
```

That last one I use a lot.

But I don't actually use the built in `ls` command anymore generally. Instead I
have symlinked it to the [exa](https://github.com/ogham/exa) program, a self
described "modern replacement for `ls`" written in Rust.

`exa` works the same as `ls`, recognizing the same options (and more) but has
built in colour support off the bat. It also understands `git`, has a nice
tree view that you can use (and augment with file attributes) and it
understands and points out symlinks with their destinations.

## cat

I really don't have much to say about `cat` it simply outputs the contents of a
file to the standard output stream of your terminal.

I will say that I tend to use `less` or `vim` when I am reading files so I can
page through them easily.

## less

`less` is like the `more` command only better (less is more!). It lets you page
through a file or output stream at your leisure.

One of the ways I tend to use less is similar to the `tail` program. If you run
less like so:

```sh
# This is the same as tail -f /var/log/my.log but better
less +F /var/log/my.log
```

You will end up following the output of a file as it is updated (it stands for
forward forever). You can stop following by press `CTRL+C` and even resume
following again in `less` by pressing `F` again.

`less` also respects the `vim` key combinations to scroll through it's output
meaning you can type `G` to scroll to the bottom of the buffer and `gg` to go
to the top which is nice!

A common command I run is `history | less` which pipes the output of history
into `less` allowing me to search it and view it more easily.

## grep

Now onto a really decent tool that everyone using a Unix terminal should at
least be aware of `grep`.

`grep` prints lines that match a pattern within a file or files.

If you want to recursively search with `grep` you can use the option `-r` for
example:

```sh
# This will search all the files under the current directory for the pattern
# "stock" and print out matching lines 
grep -r stock .
```

`grep` patterns can be more complicated than just simple words but this tends
to be the most common way I use the command.

Using `grep` with the output of other programs is where the magic is though.
For example checking for details on if a port is being used and by what process
with the `netstat` program:

```sh
# This will show any lines in the output of the netstat command that contain
# 8080 a common port used by web apps
netstat -tulpn | grep 8080
```

You can even customise the files `grep` will search through. When combined with
a more sophisticated pattern this can really help you find what you're looking
for.

```sh
# This is a case insensitive search through files ending in .dm for the given
# pattern and include their line number in the result
grep -inr --include \*.dm "?\[" .
```

Did I mention that `grep`'s patterns are Regular Expressions? Well they are and
that makes the search functionality very powerful.

There are alternatives to `grep` including `rg`
([ripgrep](https://github.com/BurntSushi/ripgrep)) that can run faster than
`grep` in recursive mode that are also worth a mention (it is also written in
Rust). However I still tend to use `grep` a lot more than any of it's
replacements.

## which

`which` is a simple command that will tell you where a command or program comes
from. For example running

```sh
which which
```

Will tell you:

> which: shell built-in command

And running:

```sh
which exa
```

Will output the path of the `exa` program: `/usr/bin/exa`.

`which` is very useful when dealing with shell scripts on your path and can be
used in combination with other programs and environment variables like so:

```sh
# Open up the passmenu bash script in an editor
vim $(which passmenu)
# Will output the path to the $BROWSER program
which $BROWSER
```

## sed

`sed` stands for "stream editor" and is a very useful program, especially when
writing bash scripts.

`sed` allows you to perform operations on the output of other commands with
ease. Unfortunately I am nowhere near familiar enough to give it justice and
tend to have to resort to the `man` file and internet when I use `sed` but
there are some great videos and tutorials around the command online including
[DistoTube's](https://www.youtube.com/watch?v=EACe7aiGczw) and [Luke
Smith's](https://www.youtube.com/watch?v=QaGhpqRll_k) YouTube videos.

Generally speaking I use `sed` to perform find and replace on files on the
command line without having to open up any kind of editor. I do this using the
in-place option `-i` and form a simple pattern. For example:

```bash
# I ran this command to remove all mention of a Third-Party font from my blogs
# CSS files
sed -i 's/"PT Sans",//g' public/css/*

# I ran this command to replace some paths in a source file during some
# refactoring
sed -i 's|/Item|/obj/item|g' code/locker.dm
```

The above example use 2 different delimiters for the find and replace parts of
my pattern. The first uses the `/` symbol to separate the sections and second
uses the `|` character. The symbol used depends on what comes after the `s`
command which tells `sed` to treat the text as a Regular Expression. You can
get `sed` to support an extended version of Regular expressions with the `-r`
option. [This video by Linode](https://www.youtube.com/watch?v=ERc3J_6qI0A)
gives a simple example:

```sh
# Use a regex to replace billy and tom's example.org email addresses with
# example.com addresses
sed -i -r 's/^(billy|tom)@.*example\.org/\1@example.com/' ~/roster.txt
```

You don't need to use the `-i` option with `sed`. Without it the result of the
`sed` command will be output to the standard output stream. One example use of
`sed` without `-i` I used recently was to extract the SHA256 hash of a
certificate without the separating `:` characters:

```sh
openssl x509 -noout -fingerprint -sha256 -inform pem -in cert.pem | sed 's/SHA256 Fingerprint=//' | sed 's/://g'
```

## file

`file` determines the kind of a file a given file is. It's pretty simple and
works most of the time regardless of the extension of a file although takes
into into account. For instance:

```sh
file host.sh
```

Outputs:

> host.sh: Bourne-Again shell script, ASCII text executable

```sh
file Makefile
```

Outputs:

> Makefile: makefile script, ASCII text

```sh
file $(which exa)
```

Outputs:

> /usr/bin/exa: ELF 64-bit LSB pie executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, BuildID[sha1]=93a7b337d26e63f8d0d723c42da8cdcea68397d8, for GNU/Linux 4.4.0, stripped

This can be really useful when dealing with files you have destroyed the
extension for and in scripts.

## Closing

These are just a few of the many commands I use often. I wrote this post mostly
as a reminder for myself and to help others with examples.
