---
title: Slow Browsing Under Ubuntu
date: 2008-08-23 21:35:23
categories:
  - Technical
---

**EDIT:** This post only covers IPv6, please check the [update post](/2010/02/speeding-up-firefox-under-ubuntu/) which covers IPv6 and Firefox

Today when I rebooted to my Windows installation which I very rarely do, I noticed that browsing under Windows feels much faster than under Ubuntu. After booting back to Ubuntu I noticed the "looking up domain.tld" part was taking a lot of time, which seemed a little odd.<!--more-->

Anyways, after some googling I found out that Debian enables IPv6 by default and uses that before and uses it before IPv4. A quick remedy was:
```bash
sudo vi /etc/modprobe.d/bad_list

#Add this line
alias net-pf-10 off
```

After which you should reboot your system. Now browsing feels much faster. To speed it up a little I installed a local caching DNS server which works like a charm. A quick HOWTO can be found [here](http://ubuntu.wordpress.com/2006/08/02/local-dns-cache-for-faster-browsing/)

Hope this helps.