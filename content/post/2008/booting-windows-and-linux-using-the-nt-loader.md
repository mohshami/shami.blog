---
title: Booting Windows and Linux using the NT loader
date: 2008-04-20 00:48:12
categories:
  - Technical
---

I recently decided to install Windows on my home PC since I wanted to play some games, it's been about 3 years since I started using Linux exclusively but thought a change would be nice. Since I didn't find good guides I decided to write my own :)<!--more-->

Why would you want to do that? Well, back when I used to dual boot on a single drive I used to re-install Windows very frequently. Windows wipes out grub during installation so I needed to keep grub on a separate partition.

This guide assumes you have 2 hard drives; one for Linux and the other for Windows, you can do the same with a single drive but with minor changes.

- Install Windows on the first hard drive
- Install Linux on the second drive, and install grub on the master boot record of that drive
- Download Grub4Dos
- Save grldr and menu.lst to C:
- Edit menu.lst and put the following:

```plaintext
title Linux
chainloader (hd1)+1
rootnoverify (hd1)
```

- Edit your boot.ini and add the following line:

```plaintext
C:GRLDR="Linux"
```

Another way to do this is using [bootpart](http://www.winimage.com/bootpart.htm). Make sure to install grub on the first sector of the boot partition because bootpart can't read master boot records.