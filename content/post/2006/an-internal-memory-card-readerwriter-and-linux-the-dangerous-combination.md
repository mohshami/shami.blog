---
title: "An Internal Memory Card Reader/Writer and Gentoo Linux; The Dangerous Combination"
date: 2006-10-14 15:14:00
categories:
  - Technical
  - Linux
---

Hello everybody, it's me again. Before I begin, I just want to say that this one's dedicated to my friend and brother Kilo, you'll love it :D.

After spending some time with my new w810i -which I love so far, I decided to get a card reader/writer to transfer files to/from the phone. Even though the USB cable that came with the phone worked like a charm, but I don't want to use it since it charges the battery as soon as the phone is plugged, and I like to charge batteries only when they die.<!--more-->

Anyways, when I went to the store to buy it, I had 2 options, an external one with a USB hub and an internal one with an extra USB outlet. I decided to go with the internal one as my desk doesn't need any more clutter.

And now for my experience with the thing. I installed it on my PC and turned it on. Since it uses the USB connector on the motherboard I thought it should be plain and simple, but if you know me at all, you'll know that nothing is plain and simple with me :(. When I connect any USB device to the outlet, the computer recognizes it and it works well, but it doesn't even say anything about them or the device itself.

Just so you'd know, I run Gentoo Linux exclusively on my desktop, so I come across hardware issues almost all the time (Not that Gentoo doesn't support them, it's because I have to do some research to get them to work).

A quick search in the Gentoo Forums (I told you you're gonna love this Kilo) told me that I have to recompile the kernel (Again, I told you) and I found out that I need to have the support to probe all LUNs in the kernel (it's in the SCSI section) to make it work.

So I go ahead and recompile, but it still didn't work :/, again I do some searches in the forum and then google, and then I found it.

You need to enable the following options (Choose whichever applies for your USB support):
```plaintext
Device Drivers——–>
SCSI Device Support ———>
legacy /proc/scsi/ support
&lt;*&gt; SCSI disk support
&lt;*&gt; SCSI generic support
USB Support ————–&gt;
&lt;*&gt; Support for USB
[*] USB device filesystem
&lt; &gt; EHCI HCD (USB 2.0) support
&lt; &gt; OHCI HCD support
&lt;*&gt; UHCI HCD (most Intel and VIA) support
&lt;*&gt; USB Mass Storage support
```

Ok, still, the device didn't show up in either lspci and nothing in /proc/scsi, but when I insert a card in the slot, the device /dev/sdd1 will act as that card, adding the following to fstab will enable regular users to mount it:

```plaintext
/dev/sdd1 /mnt/ms vfat noauto,user,sync,rw,utf8 0 0
```

sync will reduce the possibility of filesystem corruption in case the user didn't umount before removal, and utf8 is in case you wanted to have files with non-english names.

Remember, nothing will show up in dmesg or on lspci, at least for the model I bought, but the device /dev/sdd1 (or sda1 or sdb1, depending on which slot you use) will be active a few seconds after you insert the card.

Hope this will be of help to someone, and will save them some time.

Take care everybody and have a nice day,  
Shami