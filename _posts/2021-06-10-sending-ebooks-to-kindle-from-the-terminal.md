---
layout: post
title: Sending EBooks to Kindle from the Terminal
tags:
- kindle
- terminal
- linux
- email
- msmtp
- mutt
date: 2021-06-10 19:06 +0300
---
Just a quick post sharing a simple bash script for sending your EBooks to your
Kindle via email (using msmtp and mutt).

I tend to get my EBooks outside of the Kindle store. Amazon already get enough
of my money after all and I like more open formats compared to their DRM
ladened `azw` format. Luckily the Kindle supports the `mobi` format which is
widely supported by publishers and conversion tools alike.

As a way to get EBooks to your Kindle Amazon provide you with a unique email
address, this is pretty convenient if you don't have your Kindle handy and want
to put a book on it you want to later peruse. Since I already have an email
account set up on my terminal I felt like skipping the step of composing an
email manually to send books to my Kindle and script it. Below is my simple
attempt using `msmtp` via `mutt`:

```bash
#!/bin/bash
KINDLE=$KINDLE_EMAIL
BOOK=$1
MUTT=neomutt

if [ $# -eq 0 ]; then
  echo "Missing attachment as argument"
  exit 1
fi

if [ -f "$BOOK" ]; then 
  FILE_TEST=$(file -b $BOOK)

  if file -b $BOOK | grep -q "Mobipocket E-book"; then
    # for now don't support PDF as well,
    # this could be done with a pattern like "PDF document"
    echo "Sending book to Kindle: $BOOK"
    echo "Book $BOOK" | $MUTT -s "Book: $BOOK" -a $BOOK -- $KINDLE
  else
    echo "$BOOK is not a supported file type"
    exit 1
  fi

else
  echo "$BOOK does not exist"
fi
```

It's pretty simple; I do some tests to make sure I am actually sending a file
and that it is a supported book, for now I am only supporting `mobi` books but
I could also extend it to let me send PDF files if I wished.

