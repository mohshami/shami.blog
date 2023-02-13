---
date: 2021-06-04T02:14:45-04:00
title: "Why You Shouldn't Use the Windows 10 SSH Agent"
---

I have recently switched to using [Sublime Merge](https://www.sublimemerge.com/) as my Git client. I know other clients have the same features but for me Sublime Merge is just a pleasure to use.<!--more-->

One issue Sublime Merge has is it can't use SSH keys directly; It relies on using other applications in your system. That is automatically handled on MacOS and Linux, but on Windows you will have to rely on plink and pageant to do that for you.

I wanted to find a more elegant solution and discovered that Windows 10 has a built-in OpenSSH agent service. So I immediately decided to check it out. One thing I noticed was that any private key you add to this agent is loaded automatically at reboot. I found [this page](https://github.com/PowerShell/Win32-OpenSSH/issues/1487) where the developers say it's a design choice and even though many people asked them to at least make it an option they refuse to do so till today.

This rubs me the wrong way, even though the keys are stored per user in the registry and are only accessible from user account that added them it just feels like a layer of security has been removed. Just stick to pageant and you will be fine.