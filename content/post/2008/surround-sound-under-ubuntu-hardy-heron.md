---
title: Surround Sound Under Ubuntu Hardy Heron
date: 2008-04-27 22:50:18
categories:
  - Technical
---

Been using Ubuntu Hardy Heron for about a month now, and I have to say it rocks, the best Desktop Linux so far.<!--more-->

Anyways, I have a Creative Audigy 2 card since I'm not a fan of software mixing under Linux, which is connected to an old creative 4.1 set. Since I don't have any space I hooked only the front speakers and use the rear channels with a headset. After upgrading to Hardy I couldn't get the headset to work. I just found the solution on the [Ubuntu forums](http://ubuntuforums.org/showthread.php?t=595412&page=2) and thought I should document.

The new Ubuntu uses PulseAudio as it's default sound engine, you can set volume levels for each application separately which is cool if you ask me. PulseAudio uses 2 channels by default. All you have to do is change:
```plaintext
; default-sample-channels = 2
```

To:
```plaintext
default-sample-channels = 6
```

In /etc/pulse/daemon.conf, then restart gdm and you're done