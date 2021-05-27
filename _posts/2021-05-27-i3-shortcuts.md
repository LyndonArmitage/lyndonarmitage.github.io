---
layout: post
title: i3-shortcuts
tags:
- i3
- linux
- c
- dmenu
- rofi
date: 2021-05-27 15:48 +0300
---
Recently I wrote a very quick C program to parse my i3 configuration file and
output the bound keys within. This was to help jog my memory of the various
keys I have set in my configuration file beyond the common ones.

The project can be seen on my GitHub
[here](https://github.com/LyndonArmitage/i3-shortcuts).  
It's pretty simple and currently outputs the binds to standard output as
`KEYBIND\tCOMMAND`. This can be piped into a tool like
[dmenu](https://tools.suckless.org/dmenu/) or
[rofi](https://github.com/davatorium/rofi), or parsed further and used in a
[conky](https://github.com/brndnmtthws/conky) window.

For dmenu:

```bash
./i3-shortcuts | dmenu -i -l 20
```

Or rofi:

```bash
./i3-shortcuts | rofi -dmenu
```

