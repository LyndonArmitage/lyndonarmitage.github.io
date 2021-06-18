---
layout: post
title: Copying Photos off of Android using ADB
tags:
- linux
- adb
- android
- terminal
- photos
- backup
date: 2021-06-18 11:35 +0300
---
Last night I was struck by a mini disaster! My phone had run out space due to
the amount of photographs I have taken over the last few years! Annoyed at the
sudden disruption to my phones operation I went to work trying to delete old
photos and back them up.

My first stop was simply plugging my phone in and moving old photographs off of
the device using the file system. However upon enabling the file transfer I was
met with a slight problem. Android phones communicate their file system using a
protocol called `mtp` that is Media Transfer Protocol in long-speak. So my
device was not present as a simple file mount, at least not on first glance. So
using tools like `find` and `xargs` seemed to become quite difficult. I tried
to quickly move files using a graphical file browser (PCManFM) but this just
seemed to freeze and not do anything.  
I read that you can access these shown files on the file system but was unable
to get this working.

So I was stuck an as I stared at the internet and keyboard I found a few
options:

* I could use some app to copy files over SSH
* I could use some app to copy files over FTP (or SFTP)
* I could use the Android Debugging Bridge (`adb`) to push and pull files from
  my Android phone.

Those first 2 options seemed great! Unfortunately I had one major problem, I am
currently in a place without WiFi. So my phone is on 4G and my laptop connected
to the internet via a cable. I could in theory create a hotspot and fiddle with
all the settings but it was around 1AM at this time and it seemed like
overkill. So instead I wanted to look at the last option, `adb`.

I had used `adb` years ago for a much older version of Android but by some
fluke had it installed on my laptop. So my first attempt was to just push a
file to my device. This failed. I had forgotten to enable `adb` on my device.
Some frantic pressing of about information later and I was a "Developer" on my
phone and enabled the bridge connection.

Suddenly I could access my phone in a more familiar way! I could push and pull
files from it with ease and I could run a simple shell on my phone!

This is where I found that my phone has some existing familiar Linux tools
readily available namely `find`.

With `find` installed all I had to do was run a simple command to find all the
images in my camera folder over a certain age, collate these into a file,
transfer this file to my pc and run an `adb pull` on each of the files to pull
them off of my phone and onto a backup drive! Then on the phone I could run
`rm` on each of these files.

Now I am sure I could have used `xargs` to do something without an intermediate
file but I was nervous about deleting the wrong files so opted to practice some
vim-fu on the file to create simple script files.

After doing this once for photographs over 3 years old I did the same
progressively for younger images and restored my phones storage to something a
bit more sane!

