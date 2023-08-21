---
title: Microsoft Keyboard Function Key Fix
date: 2008-07-14 19:18:36
categories:
  - Technical
---

I've owned a Microsoft MultiMedia Keyboard 1.0A for years now. It's a well belt keyboard to say the least. Only one problem though, the "F Lock" key. As a Linux user I have no use for the "Special" keys Microsoft added to the keyboard, and the button always starts turned off, no way to fix it.<!--more-->

I used to keep my PC on at all times so I only needed to press that button every couple of months, or when I want to take a screenshot, but now I started to turn it off at night, and having to press that stupid button every time I boot my system is a huge pain in the butt.

I found a fix for it [here](http://www.linuxquestions.org/questions/linuxanswers-discussion-27/discussion-microsoft-keyboard-function-key-fix-248618/) and thought I should share

```plaintext
vi /usr/local/bin/f_lock_fix
setkeycodes bb 59 # Help  -> F1
setkeycodes 88 60 # Undo  -> F2
setkeycodes 87 61 # Redo  -> F3
setkeycodes be 62 # New   -> F4
setkeycodes bf 63 # Open  -> F5
setkeycodes c0 64 # Close -> F6
setkeycodes c1 65 # Reply -> F7
setkeycodes c2 66 # Fwd   -> F8
setkeycodes c3 67 # Send  -> F9
setkeycodes a3 68 # Spell -> F10
setkeycodes d7 87 # Save  -> F11
setkeycodes d8 88 # Print -> F12
chmod 700 /usr/local/bin/f_lock_fix
```

Now add this to your startup file "/etc/rc.local" or equivalent

```bash
if [ -x /usr/local/bin/f_lock_fix ]; then
	echo "Fixing the F-Lock scan codes for F1-F12 keys...";
	/usr/local/bin/f_lock_fix;
fi
```