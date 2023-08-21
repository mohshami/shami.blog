---
title: Speeding up Firefox under Ubuntu
date: 2010-02-14 11:16:08
categories:
  - Linux
---

Ever wonder why browsing under Ubuntu is slower than Windows even on the same network? Well, it has to do with Ubuntu enabling IPv6 by default. This means Ubuntu will try IPv4 only after IPv6 times out. Also, Firefox comes built with Pango by default which makes it slower than it should be. I've fixed that on Karmic Koala, other versions should be similar. Here's how to do it:<!--more-->

**Disable IPv6 globally:**

```bash
sudo vi /etc/default/grub
```

then find

```plaintext
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
```

 and replace it with

```plaintext
GRUB_CMDLINE_LINUX_DEFAULT="ipv6.disable=1 quiet splash"
```

 Then update grub from the command line

```bash
sudo update-grub
```

**Tell Firefox not to load Pango:**

```bash
vi ~/.bashrc
```

and add

```plaintext
MOZ_DISABLE_PANGO=1
```

at the end

**Tweak Firefox's about:config settings:**

- network.http.pipelining -> True
- network.http.pipelining.maxrequests -> 8 or 10
- network.http.proxy.pipelining -> True
- network.dns.disableIPv6 -> True```

Enjoy