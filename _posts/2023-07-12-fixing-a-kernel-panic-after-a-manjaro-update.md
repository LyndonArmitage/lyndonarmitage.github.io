---
layout: post
title: Fixing a Kernel Panic after a Manjaro Update
tags:
- linux
- kernel
- error
- panic
- manjaro
date: 2023-07-12 11:46 +0100
---
This morning I ran into a major issue with my Manjaro Linux install. After an
update and a reboot I was faced with this error (cut for brevity):

```
Initramfs unpacking failed: invalid magic at start of compressed archive
Kernel panic - not syncing: VFS: Unable to mount root fs on unknown-block(0,0)
CPU: 0 PID: 1 Comm: swapper/0 Not tainted 5.4.249-1-MANJARO #1
```

I tried the usual first step of recovering from such an issue, that is to load
into a different kernel version. Only to be met with the same error. Not good.

I was able to load into the GRUB interface, and confirm that my file system
still had files on it using `ls`, but was stumped as to what to do next.

As with any kind of issue, it pays to search the web for others experiencing
the same or similar problem. So after a few minutes of searching I came upon
this awesome thread on the Manjaro forums:

https://forum.manjaro.org/t/initramfs-unpacking-failed-invalid-magic-as-start-of-compressed/137451

It along with the related threads explained the issue. In short:

A recent change altered the defaults used by a key piece in the way the Kernel
is built. Instead of using GZIP as the default for compression it uses ZSTD.
And as a result earlier Kernels fail to mount the file systems.

As user Uberpanda states in that thread, the solution is *relatively* simple:

> Reinstalling by itself does not suffice. Here is the problem :
> For some reason, `mkinitpcio` now creates zstd compressed images instead of
> the previous default gzip.
> kernels 5.4 and 4.19 cannot read these images.
> A workaround is to uncomment
> 
> ```
> COMPRESSION=“gzip”
> ```
> 
> in `/etc/mkinitpcio.conf`, and rebuild with
> 
> ```
> mkinitcpio -P
> ```
> 
> I am not sure if there is a way to make 5.4 and below able to read zstd.

But in order to do this you need a loaded kernel. If I had a newer kernel
installed that would have been simple. Unfortunately, I did not. So I needed to
create a live USB using another computer and an image from 
https://manjaro.org/download/

I did this on a Windows PC using [Rufus](https://rufus.ie/en/) to format the
USB.

With that USB inserted I hammered the F12 key on boot and successfully booted
into the OS on the USB. The next step was to change my root to the existing
file systems on the hard drive rather than the USB.

This is normally a simply case of running the following as a super user:

```
manjaro-chroot -a 
```

Unfortunately, it was not this simple for me because my hard drive is LUKS
encrypted. With much fustration I found [this
post](https://forum.manjaro.org/t/solved-can-not-mount-partition-to-manjaro-chroot-from-live-usb/46119/2_
on the same Manjaro Forum. From it and consulting the man pages for the command
`cryptsetup`, I found that in order to mount my file system I needed to run the
following:

```
cryptsetup open /dev/sda6 e6
mount /dev/mapper/e6 /mnt
mount /dev/sda1 /mnt/boot/efi
```

The first allowed me to map the encrypted device (in my case it was
`/dev/sda6`), with the encryption key that I then provided, to the name `e6`
(the name was not really important).

Then I was able to mount the mapped file system to `/mnt`. To confirm this I
was able to `ls` all my existing files from my hard drive, which meant at this
stage I could copy any vital files to another USB if needed.

The next step was to mount the boot partition into the appropriate location. I
think it is convention for this to normally be your first partition, but at any
rate it is almost always a very small partition, which you can confirm using
the command `lsblk` to list your block devices.

Then I was able to run the following command:

```
manjaro-chroot /mnt
```

Which dropped me into a new shell where I could edit `/etc/mkinitcpio.conf`,
removing the comment for the GZIP line.

Then I ran:

```
mkinitpcio -P
```

And watched as it succeeded. I then exited the current shell (I used CTRL+D but
the `exit` command also works). And unmounted the file systems in this order:

```
umount /mnt/boot/efi
umount /mnt
```

After one final reboot I was able to use my Linux machine again!
