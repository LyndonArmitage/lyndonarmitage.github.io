---
layout: post
title: Centering mouse in the Active Window
tags:
- linux
- i3
- shell
date: 2021-04-26 13:17 +0100
---
This is just a quick post on how to centre your mouse in the currently selected
window on Linux.

This is behaviour that can be patched into `dwm` but for window managers like
`i3` you will need to call this script whenever you perform an action that you
want to shift your mouse's focus.

```bash
#!/bin/sh

ACTIVE_WINDOW_ID=$(xdotool getactivewindow)
DIMS=$(xdotool getwindowgeometry -shell $ACTIVE_WINDOW_ID | awk -F "="  'NR==4,NR==5 {print $2/2}' | tr '\n' ' ')

xdotool mousemove -w $ACTIVE_WINDOW_ID $DIMS

```

A quick explanation of this:

1. `xdotool getactivewindow` will return the active window's ID
2. `xdotool getwindowgeometry -shell $ACTIVE_WINDOW_ID` will then get that
   window's geometry.
3. `awk -F "="  'NR==4,NR==5 {print $2/2}'` will run on the geometry command's
   output, splitting each line on the `=` symbol.  
   The `NR==4, NR==5` will match the 4th and 5th line (width and height).  
   And finally the print command will output the second match on each line
   (the value after the `=`) divided by 2.
4. The `tr` command will take each line of the output and replace the new line
   characters with a space.
5. Finally `xdotool mousemove -w $ACTIVE_WINDOW_ID $DIMS` will move the mouse
   to the active window at the given positions (the middle).

With `i3` I altered my config so that after every change focus command I
execute the above little script. E.g.

```i3
# Set script to centre mouse
set $centre_mouse ~/.config/i3/centre-mouse

bindsym $mod+Left focus left; exec --no-startup-id $centre_mouse
bindsym $mod+Down focus down; exec --no-startup-id $centre_mouse
bindsym $mod+Up focus up; exec --no-startup-id $centre_mouse
bindsym $mod+Right focus right; exec --no-startup-id $centre_mouse
```

I thought I'd share this for anyone else wanting something similar as I saw a
[thread on Reddit](https://www.reddit.com/r/i3wm/comments/5j11sd/more_mouse_warping/)
from a few years ago where someone was asking for such.

