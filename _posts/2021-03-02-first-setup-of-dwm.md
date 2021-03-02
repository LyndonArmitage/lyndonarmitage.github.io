---
layout: post
title: Fist Setup of dwm
tags: [linux,dwm,i3,suckless]
---

After many years of happily using the [i3 window manager](https://i3wm.org/)
in my Linux environment I have decided to try to use the Suckless Dynamic
Window Manager, [dwm](https://dwm.suckless.org/), as a replacement.  
I am not unhappy with i3 as such but do get mildly irritated from time to time
with having to manually manage my workspaces and the configuration file. I
would also like to get more practice in C programming and since dwm is in
written and configured in C it seems like a good way to do this.

<img
  alt='dwm logo'
  title='dwm logo'
  src='{{ "assets/dwm/dwm.png" | absolute_url }}'
  class='blog-image'
/>

Because of the Suckless philosophy the best way to install dwm is to build it
from source and [customise](https://dwm.suckless.org/customisation/) it there.
Thankfully this is not as hard as it sounds since it is a relatively small C
program.

So I started by cloning the dwm repository and creating my own personal mirror
of it in Git. I made sure to maintain an upstream remote to the original
repository in order to port core improvements as they come.

The first thing I tried was to just run `make` on the directory since it uses
as simple [Makefile](https://www.gnu.org/software/make/) as it's build system.
This worked fine with no issues on my machine and produced the various `.o`
files, a `config.h` file and a `dwm` binary in place. Excellent!

Reading the readme file I found that in order to install it you should run

```bash
sudo make install
```

So this is exactly what I did! And it succeeded in installing dwm and it's man
pages onto my system (I use Manjaro).

So next I decided to log out and try the window manager for myself.
Unfortunately it was not an option on my display manager (the login screen).
Curious as to why I did some searching online and found that many display
managers rely on desktop entry files to be present in `/usr/share/xsessions`
(courtesy of the
[Arch Wiki](https://wiki.archlinux.org/index.php/Display_manager#Session_configuration))
so I went to work writing one for dwm! In fact I added it to the Makefile so
that when I run `sudo make install` it is automatically added and when I come
to uninstall dwm it will be automatically removed.

For those who stumble upon this and want to know quickly what kind of desktop
entry they need, below is what I used:

```text
[Desktop Entry]
Name=dwm
Comment=suckless dynamic window manager
Exec=/usr/local/bin/dwm
TryExec=/usr/local/bin/dwm
Type=Application
X-LightDM-DesktopName=dwm
DesktopNames=dwm
Keywords=tiling;wm;windowmanager;window;manager;
```

Now after again running `sudo make install` I have a desktop entry ready for
use and dwm appears in my display manager.

However as part of reading I realised I need to change a few things before just
testing dwm, one of them being the Mod key used. In i3 I am very used to using
the Windows key present on many keyboard, or Mod4 key (the other 3 being ALT,
CTRL and SHIFT) so I made my first change in the `config.h` file that had been
generated.

```c
/* key definitions */
#define MODKEY Mod4Mask
```

Additionally I altered the terminal to use `urxvt` instead of `st`.

```c
static const char *termcmd[]  = { "urxvt", NULL };
```

Now I could start up dwm with mostly default key bindings.  
Obviously there's a lot more to do to get dwm up to the same level of niceness
as my i3 install but now I have the framework in place I can start to explore
existing patches people have released for it that add useful and desired
features and configure it to my hearts content. Thankfully because of the way I
have installed it I can always switch back to my i3 setup when needed and
because I will be using Git to catalog all my changes I can modify without risk
of permanently breaking anything.
