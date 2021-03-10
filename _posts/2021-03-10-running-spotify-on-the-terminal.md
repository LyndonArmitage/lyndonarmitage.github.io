---
layout: post
title: Running Spotify on the Terminal with spotifyd & spotify-tui
date: 2021-03-10 17:00 +0000
tags:
- linux
- spotify
- music
- command line
- playerctl
- spotifyd
- rust
---
If you like your music, have a Spotify account and use Linux then `spotifyd`
and `spotify-tui` might be nice alternative to using a heavier GUI client.

[spotifyd](https://github.com/Spotifyd/spotifyd) is a simple daemon service
for allowing you to play Spotify on your device, it can even be run on a
Raspberry Pi if you want to create your own internet enabled speaker!
Unfortunately it requires a Spotify Premium account but it is very simple to
setup.

[spotify-tui](https://github.com/Rigellute/spotify-tui) is a simple command
line UI for controlling Spotify, you don't actually have to use it with
`spotifyd` as it can control any of your Spotify enabled devices. This includes
playing it "Everywhere".

Both are written in Rust so can produce binaries for most devices. `spotifyd` is
actually present in the Arch community repositories and `spotify-tui` is
present in the [AUR](https://aur.archlinux.org/packages/spotify-tui) (note the
build time for `spotify-tui` can take quite a while).

Once installed you just need to setup your authentication for both and then you
can control and listen to your Spotify on the command line. `spotifyd` requires
your username and password whereas `spotify-tui` uses a token to access your
Spotify account. The command for `spotify-tui` is actually `spt`.

If you don't like `spotify-tui` you can control it using something like
[playerctl](https://github.com/altdesktop/playerctl) since `spotifyd` registers
itself on the D-BUS interface. This actually allows you to potentially bind
shortcut keys to control your music since you can write a simple command like:

```bash
playerctl -p spotifyd play-pause
```

To pause and resume your music. In fact with `playerctl` you can omit the
player option and let it use the last player in use allowing you to control
both Spotify and other media players.  
Additionally `playerctl` let's you get the metadata from your player so you can
do all sorts with this e.g.


```bash
playerctl metadata --format "Now playing: {% raw %}{{ artist }} - {{ album }} - {{ title }}{% endraw %}"
```

And because `spotifyd` is separate to `spotify-tui` you also don't need to keep
`spotify-tui` running.
