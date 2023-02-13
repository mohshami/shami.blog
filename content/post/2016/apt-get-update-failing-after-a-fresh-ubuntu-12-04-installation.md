---
title: "'apt-get update' Failing After A Fresh Ubuntu 12.04 Installation"
date: 2016-05-02 10:51:09
categories:
  - Technical
---

So I'm currently working with a customer that requires Ubuntu 12.04 for their servers since their apps were built and tested on that version, so every new install I run into the following issue<!--more-->

```none
W: Failed to fetch bzip2:/var/lib/apt/lists/partial/jo.archive.ubuntu.com_ubuntu_dists_precise_main_binary-i386_Packages  Hash Sum mismatch
```

This can be easily solved using the following commands, taken from [here](http://askubuntu.com/questions/297757/why-after-fresh-ubuntu-12-04-installation-update-arent-being-installed)

```bash
sudo rm /var/lib/apt/lists/* -vf
sudo apt-get clean
sudo apt-get autoremove
sudo apt-get update
```