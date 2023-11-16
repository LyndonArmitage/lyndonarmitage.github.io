---
layout: post
title: Refreshing my NeoVim Installation
tags:
- linux
- vim
- terminal
- programming
---

As I mentioned many moons ago, I use the text editor
[Vim](https://www.vim.org/about.php) as one of my daily drivers. To be exact I
actually use [NeoVim](https://neovim.io/). Recently I have decided to clean up
my configuration files. I plan on documenting that adventure here.

Initially, I decided to try and keep my Vim config compatible with both Vim and
NeoVim. This meant sticking to the Vim-specific vimscript for configuration and
not moving onto the [Lua](https://www.lua.org/about.html) based configuration
native to NeoVim, or installing plugins that would fail to work with Vim.

I've since lightened my approach on plugins, since I am only using this
configuration on machines with NeoVim installed. And seeing as this means my
config will only work on NeoVim it makes sense to transition the whole
configuration into the more NeoVim friendly format Lua.

Lua is a fantastic little scripting language specifically built for embedding
inside other applications so that you can extend their functionality
dynamically. I first encountered it when playing around with the video game
[Garry's Mod](https://gmod.facepunch.com/), which uses Lua to allow mod makers
to build all sorts of things into the Source Engine that the game is built on.

ThePrimeagen has a [video from the end of
2022](https://www.youtube.com/watch?v=w7i4amO_zaE) where he quickly goes
through setting up a NeoVim configuration, which I will be drawing some
inspiration from. Likewise, I will be referring to a handful of useful blog
posts along with the [Lua
guide](https://neovim.io/doc/user/lua-guide.html#lua-guide).

## Plugins

Currently, I am using [vim-plug](https://github.com/junegunn/vim-plug) to
manage the installation and updates for all 34 of my plugins. I'd like to
switch out the management to a NeoVim native package manager.
[packer.nvim](https://github.com/wbthomason/packer.nvim) seemed to be the
suggested manager, but it has become unmaintained in 2023 and recommends either
[lazy.nvim](https://github.com/folke/lazy.nvim) or
[pckr.nvim](https://github.com/lewis6991/pckr.nvim). I will decide what plugin
manager to use when I get to actually trying them out.

Now, I could just take the plugins I already have and import each one with the
new plugin manager, but this is a great opportunity to trim the fat and remove
those that I either no longer use, or can live without. Since I can always
install them again if desired I can be quite strict with how much I remove.  
My current list of plugins is as follows:

```vim
Plug 'junegunn/vim-plug'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-commentary'
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/syntastic'
Plug 'airblade/vim-gitgutter'
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'
Plug 'PotatoesMaster/i3-vim-syntax'
Plug 'aklt/plantuml-syntax'
Plug 'uarun/vim-protobuf'
Plug 'rhysd/vim-grammarous'
Plug 'wlue/vim-dm-syntax'
Plug 'udalov/kotlin-vim'
Plug 'roxma/vim-paste-easy'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'rust-lang/rust.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'geverding/vim-hocon'
Plug 'junegunn/limelight.vim'
Plug 'junegunn/goyo.vim'
Plug 'vimwiki/vimwiki'
Plug 'jalvesaq/Nvim-R', {'branch': 'stable'}
Plug 'andlrc/rpgle.vim'
Plug 'https://tildegit.org/sloum/gemini-vim-syntax'
Plug 'tweekmonster/startuptime.vim'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'Yggdroot/indentLine'
Plug 'jparise/vim-graphql'
Plug 'preservim/vim-pencil'
Plug 'ziglang/zig.vim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
```

Obviously, I can remove `junegunn/vim-plug`, but there are many others I can
dump.

[vim-fugitive](https://github.com/tpope/vim-fugitive) is a fantastic Git plugin
that I often use and will keep. The other plugins by Tim Pope I don't see
myself using any more, at least not knowingly, so will discard. That
eliminates 4 plugins.

[NERDTree](https://github.com/preservim/nerdtree) is a nice file system
explorer built for Vim that I use daily. However, I want to switch to using a
fuzzy finder for navigating between files in a project so will initially remove
this plugin. Interestingly, I had installed
[ctrlp.vim](https://github.com/ctrlpvim/ctrlp.vim) already which is a fuzzy
finder tool, but have not been using it, so I think I will remove this and use
a different plugin.

[syntastic](https://github.com/vim-syntastic/syntastic) was a syntax
highlighting plugin, but it turns out it is no longer maintained, so I will be
dumping it in favour of other solutions, likely
[nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter), which I
already have installed but seldom use.

[vim-gitgutter](https://github.com/airblade/vim-gitgutter) is plugin that shows
what lines have changed in a file next to the line number. It's pretty useful
just as a visual aid, but being strict on what I keep, I will initially not
reinstall it.

I will not install [tabular](godlygeek/tabular) for now, as I want to rely on
other programs to reformat code appropriately and haven't actually used it in a
long time.

When it comes to the various other syntax highlighting plugins I have
installed, I will not be reinstalling them and instead be relying on
[tree-sitter](https://tree-sitter.github.io/tree-sitter/) and
[nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter). Any
programming languages not supported by tree-sitter I will consider adding a
plugin for.

[coc.nvim](https://github.com/neoclide/coc.nvim) is a plugin that attempts to
integrate the code completion tools that work in Visual Studio Code inside
NeoVim. It's one of the plugins I added that broke my initial compatibility
with Vim mantra. It is also quite a complicated plugin to use so, initially, I
will go with the recommendation from ThePrimeagen's video and use
[lsp-zero.nvim](https://github.com/VonHeikemen/lsp-zero.nvim) for my code
completion plugin along with
[nvim-metals](https://github.com/scalameta/nvim-metals) specifically for Scala.

[startuptime.vim](https://github.com/tweekmonster/startuptime.vim)
is just a plugin for measuring startup time, which can be dumped.

[vim-paste-easy](https://github.com/roxma/vim-paste-easy) is a plugin to
automatically turn `paste` on and off when Vim detects you typing at a very
fast speed, useful, but it might be superfluous, so I will strip it out for
now.

[vim-pencil](https://github.com/preservim/vim-pencil),
[limelight.vim](https://github.com/junegunn/limelight.vim), and
[goyo.vim](https://github.com/junegunn/goyo.vim) are all plugins for turning
Vim into a better tool for traditional writing. I haven't used any of them for
a while, so they can be removed. Although, vim-pencil might be useful to
install again later.

[vim-grammarous](https://github.com/rhysd/vim-grammarous) is a plugin that
manually runs LanguageTool over your buffer. I've not used it for a while as I
have relied on other tools to grammar check my writing so it can go.

[indentLine](https://github.com/Yggdroot/indentLine) is a plugin for
adding nice vertical bars in Vim for different indentations, unfortunately,
it's no longer maintained, so I will be removing it and looking for an
alternative as I quite like the ability to see such at a glance.

[vim-airline](https://github.com/vim-airline/vim-airline) and
[vim-airline-themes](https://github.com/vim-airline/vim-airline-themes) are
plugins for producing a nicer statusline at the bottom of each Vim window. I
will try and keep these as I like the at a glance information that is
displayed.

That should cover the majority of plugins in that above list. Those I haven't
mentioned I will likely remove.

## Configuration

My current configuration is all done using vimscript to maintain compatibility
with Vim. I've actually put it in a file called `~/.config/nvim/vimrc` and have
NeoVim source this file in `~/.config/nvim/init.vim` like so:

```vim
" This is how you source and share the original .vimrc file
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.config/nvim/vimrc
" Should make sure that ~/.vimrc is symlinked to the .vimrc here
```

For compatibility with regular old Vim I have `~/.vimrc` symlinked to this
`vimrc` file.

For transitioning to using Lua for NeoVim only I will be replacing the
`init.vim` file with `init.lua` and eventually deleting the old vim files.  
Before I do that however, I need to look into the current configuration I have
set in my `vimrc` file.

At the very top of the file I have something that will automatically install
vim-plug if it isn't already installed.

```vim
" Automatic install of plug if it does not exist
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
```

Below that is then the section with all the plugins I want to install, as
mentioned previously.

```vim
call plug#begin('~/.vim/bundle') " Using same dir as Vundle
" all the Plug entries
call plug#end()
```

Afterward comes all the interesting configuration.

First up I was turning off vi compatibility mode:

```vim
set nocompatible
```

This gets rid of some old idiosyncrasies from the days of the Vi editor that
Vim was an improvement on. This isn't needed in NeoVim as it is always set.

Following that is a lot of configuration for the installed plugins. Any of
these I am getting rid of I can safely ignore in my new configuration. This is
actually the majority of them, since a lot deal with mapping keys to use plugin
features.

Beyond that there are some more generic settings, especially when it comes to
different file formats editing experiences. For example, I have this for
markdown files:

```vim
" Specific markdown file settings
augroup markdown
    autocmd FileType markdown,md call SetMarkdownOptions()
    function SetMarkdownOptions()
        set colorcolumn=80,100,120
        set textwidth=79
        set spell
        set formatoptions+=tcq
        " IndentLine ovverrides conceallevel
        let g:indentLine_enabled=0
        let g:vim_markdown_conceal = 0
        set conceallevel=0
    endfunction
augroup END
```

This sets up a few defaults that I like when editing markdown, including column
highlights, line breaking and spell checking. It also sets some plugin specific
settings.

I do this for quite a few different file formats, so it is something I will
need to convert to Lua. Thankfully, there is some guidance to this in the [Lua
Guide](https://neovim.io/doc/user/lua-guide.html#lua-guide-autocommands-group).
For example, if I wanted to convert the above to Lua it would look something
similar to this:

```lua
local markdown_group = vim.api.nvim_create_augroup(
  'markdown',
  { clear = false }
)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown,md",
  group = markdown_group,
  callback = function(args)
    -- configuration goes in here
    vim.opt.colorcolumn = { 80, 100, 120 }
    vim.opt.textwidth = 79
    vim.opt.spell = true
    vim.opt.formatoptions:append("tcq")
    vim.opt.conceallevel = 0
    -- etc
  end,
})
```

Another thing I configure is persistent undo.

```vim
if has('persistent_undo')
  " https://vi.stackexchange.com/a/53
  " Let's save undo info!
  if !isdirectory($HOME."/.vim")
      call mkdir($HOME."/.vim", "", 0770)
  endif
  if !isdirectory($HOME."/.vim/undo-dir")
      call mkdir($HOME."/.vim/undo-dir", "", 0700)
  endif
  set undodir=~/.vim/undo-dir
  set undofile
endif
```

I am actually going to enhance this with
[undotree](https://github.com/mbbill/undotree) and a minimal configuration akin
to:

```lua
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undo-dir"
vim.opt.undofile = true
```

This actually covers 90% of what I do in my Vim config. The rest of it is
mostly key bindings for plugins or various settings for the plugins.

As an example of the key bindings I use, here are some that map the arrow
keys to no-ops in normal mode:

```vim
" Crazy idea: disable arrow keys in normal mode
" http://vimcasts.org/blog/2013/02/habit-breaking-habit-making/
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>
```

In Lua these would become:

```lua
vim.keymap.set("n", "<Up>", "<NOP>")
vim.keymap.set("n", "<Down>", "<NOP>")
vim.keymap.set("n", "<Left>", "<NOP>")
vim.keymap.set("n", "<Right>", "<NOP>")
```

## Doing the Replacement

Now that I've gone over the various parts of my Vim configuration and the ways
I will be changing it, it's time to get to it!

### Slimming Down the Original Configuration

To start I will actually slim down my existing configuration by deleting the
various plugins I no longer use. I use git to keep my Vim configuration
versioned, so this will help me have an escape point I can revert to if my
attempts fail or if I want to use my older configuration on a regular Vim
install.

Next, I will remove the plugins I do currently use but won't be carrying
forward, at least initially.

Since I use vim-plug currently, I will be removing the plugins a few at a time
from my `vimrc` file and using the command `:source %` to resource the file
then `:PlugClean` to clean-up the folders for the plugin.

Once I get to a minimal stage that I am happy with, I will take the minimal
config and completely replace it with the new `init.lua` way.

As a point of interest, this is how small I got my plugin list while writing
this part of the blog post:

```vim
Plug 'junegunn/vim-plug'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'plasticboy/vim-markdown'
Plug 'PotatoesMaster/i3-vim-syntax'
Plug 'roxma/vim-paste-easy'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'geverding/vim-hocon'
```

Some of these only exist because I want a pleasant experience editing this file
and others I currently have open. It will be even shorter in the first Lua
draft.

With that all I done, I will get back to this post after doing the replacement.

### Performing the Actual Replacements

Performing the actual replacement was a little harder than I initially thought.
I had previously thought I'd use one of the newer plugin managers but
eventually settled on the currently unmaintained Packer plugin manager due to
the simplicity of using it and the support for it around the internet. This
isn't ideal but hopefully someone picks up maintenance of Packer soon.

As for plugin installs, they were relatively easy once I got going with Packer.
That includes some Language Server Protocol plugins, although I have yet to go
in-depth with configuring them.

With tree-sitter I had to install both markdown parsers in order to get correct
parsing of links in markdown files.

One issue I ran into was some colour support when using `tmux`. This is only
minor, but for some reason a handful of colours are not quite the same between
`tmux` and my raw terminal. Mainly it's squiggly underlines for spelling
mistakes in markdown files that show up in white rather than red. I've tried a
few things with `tmux` settings and concluded that it might be an issue with
the terminal emulator `alacritty` that I am using, as other terminals behave
slightly differently (`st` for instance cannot do the squiggly underlines at
all).
