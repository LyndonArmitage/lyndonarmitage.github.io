---
layout: post
title: Moving from Packer to Lazy.nvim
tags:
- linux
- vim
- terminal
- programming
date: 2025-02-05 10:37 +0000
---
[Previously]({% post_url 2023-11-28-refreshing-my-neovim-installation %}) I
mentioned that I use NeoVim as my editor of choice and updated to using
[Packer](https://github.com/folke/lazy.nvim) as a plugin manager. At the end of
January 2025 I decided to finally migrate away from the unmaintained Packer
project to [Lazy.nvim](https://github.com/folke/lazy.nvim).

This migration went much smoother than I anticipated. I won't go as heavy into
the details as I did in my previous post on moving from
[vim-plug](https://github.com/junegunn/vim-plug) to Packer, but sufficed to say
moving from one Lua based package manager to another is much simpler than
migrating from Vimscript to Lua. I mostly followed the information from
[Lazy.nvim's documentation
site](https://lazy.folke.io/usage/migration#packernvim) and also peeked at
[LazyVim configurations](http://www.lazyvim.org/) for some inspiration.

The only big change was going from
[lsp-zero.nvim](https://github.com/VonHeikemen/lsp-zero.nvim) to managing my
own LSP plugins. Thankfully, the folks responsible for `lsp-zero.nvim` opted to
alter their
[documentation](https://lsp-zero.netlify.app/docs/getting-started.html) to
covering this very issue.

Other smaller changes included moving a lot of my configuration from Lua files
in `after/plugin/` into the same place their lazy loading was defined.
Although, some still remain, I've done this with a great deal of my plugin
configuration which has kept definitions and configuration together.

I initially had an issue with autocompletion being duplicated. This turned out
to be a user error on my part as I had installed 2 competing autocompletion
engines. I also had some troubled getting snippets to show up in my
autocompletion, which again was simply a misconfiguration on my part.

After getting my main plugins working, I opted to slowly alter plugins to
lazily load when possible. Unlike others, I am not obsessive over millisecond
benchmarks when it comes to opening my editor, but delaying some of the more
resource hungry plugins from starting when not needed is always good practice.

The actual process to get back to a state similar to what my Packer based
configuration had given me took less than a day.
