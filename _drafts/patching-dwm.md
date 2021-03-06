---
layout: post
title: Patching DWM
tags:
- linux
- dwm
- suckless
- i3
---

So far I have not spent an extended period working within
[dwm](https://dwm.suckless.org/), I have however applied a whole bunch of
patches to it and even partially customised it myself and I must say it wasn't
as painful as I thought it might be.

Mostly the process boils down to browsing suckless' patches list, downloading
a patch and applying it in git with either `git apply` or `git am`, I have vim
setup as my merge tool and when I encountered conflicts it was normally a
simple case of taking both the current changes and the changes from the patch
and melding them together, 9 times out of 10 this was just adding in both lines
from my current version and the patch file.

I only encountered one patch that caused my build of dwm to succeed but running
it to crash and that was to do with having applied both an alpha/transparency
patch and a status bar patch. Because I am a lazy developer my first port of
call was to search for the issue online, this ended up getting me to the dwm
subreddit where I found someone who has a similar issue and answers from others
who solved it.
See
[this Reddit comment](https://www.reddit.com/r/dwm/comments/aqlicx/z/ei3o8id)
for the source.  
Basically, a function had changed it's signature to accommodate the alpha patch
however the statusbar patch used the same function but in such a way as it
still matched the same signature. Long story short I changed:

```c
XFillRectangle(dpy, systray->win, drw->gc, 0, 0, w, bh);
```

To

```c
XFillRectangle(dpy, systray->win, XCreateGC(dpy, root, 0 ,1 NULL), 0, 0, w, bh);
```

In the `drw.c` file.

So far I have applied the following patches in order:

* attachasideandbelow
* alpha
* autostart
* decorhints
* fibonacci layout
* fullgaps
* swallow
* systray
* restartsig
* cyclelayouts
* cursorwarp

Additionally I modified my dwm to incorporate an extra autostart feature, I
added an autostart_once file support. This basically lets me have a file that
dwm will run once automatically on start but not run again upon restarting. I
did this by writing a file to the `/tmp` directory that is checked for on start
up, additionally it is deleted on quit but not on restart.  
Of course if dwm crashes the file remains but then it is as simple as deleting
it manually, additionally because it is in the `/tmp` directory it will be
deleted automatically on a reboot so if my PC encounters some kind of fatal
error the autostart_once file will be run again.

Adding autostart_once was relatively simple! I simply added to the existing
autostart function a line that checked if both the autostart_once script file
existed and that the file in `/tmp` does not exist. Then I got it to write out
an empty file after running that script. In the quit function of dwm I added
that same temporary file to be deleted if dwm wasn't restarting and it all just
worked! I now use this file to start up things like NetworkManager, VolumeIcon
ClipIt, PamacTray etc.

I will say the most annoying thing that happened during this process is that I
accidentally blatted part of my i3 config file whilst trying to copy some of
the settings from it. I had to copy some old configuration from various places
online and the default config file (which seems to have changed since my
install of Manjaro). This is my own fault as I was not storing my i3 config in
version control, you live and you learn I guess!

I am still not _100%_ sold on dwm's philosophy of everything thing being
configured in the source file. There are some things that I think might be
better suited to being in a configuration file like settings for how various
windows should be treated or which programs to use for the web browser or
terminal. But the beauty of dwm is that I am free to add in a configuration
file if I so please! In fact I am willing to bet it would not be _too_
difficult to do so; I can use an existing single header library for processing
some common format like JSON and hook into the start up of dwm.

Anyway stay posted for my next update on dwm which will hopefully happen after
I have tried using it for an extended period of time!
