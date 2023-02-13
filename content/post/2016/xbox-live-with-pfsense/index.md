---
title: "XBOX LIVE With pfSense"
date: "2016-10-07 06:14:25"
categories:
  - Technical
  - FreeBSD
---

A couple of months ago I switched from running [OpenWRT](https://openwrt.org/) on a [TL-WDR4300](http://www.tp-link.com/en/products/details/cat-9_TL-WDR4300.html) to running [pfSense](https://pfsense.org) on a [Netgate RCC-VE 2440](http://store.netgate.com/ADI/RCC-VE-2440.aspx). Not that OpenWRT is bad, it's only because I'm a big fan of FreeBSD and I've been wanting to run a similar setup ever since I discovered custom firmware like DD-WRT and afterwards m0n0wall and [Soekris](http://soekris.com/). When I finally decided to get the hardware I thought Netgate had a better offering and I went for it.<!--more-->

I haven't been gaming much lately because of my work commitments, but tonight my wife and I had some free time and thought we might play some Lego Harry Potter on the XBOX 360. When I started the XBOX I got an error saying some XBOX LIVE features might not be available. This was normal because I don't have [UPnP](https://en.wikipedia.org/wiki/Universal_Plug_and_Play) enabled as it would lead to security vulnerabilities.

To get things started quickly I enabled UPnP and restricted it to the XBOX's IP, but found out later it was enabled for other devices on the network so it seems I missed a setting somewhere. So I disabled UPnP and added the same port forwarding settings I had on OpenWRT and it still didn't work. After fiddling with it for about an hour I found out there were 2 causes:
- [Source port randomization](https://doc.pfsense.org/index.php/Static_Port): pfSense does this by default because many operating systems do it poorly, if at all. This eliminates some potential (but unlikely) security vulnerabilities but breaks the XBOX LIVE protocol.
- Having previously enabled UPnP: Even though I had all settings in place the XBOX LIVE test kept failing, seems the UPnP state didn't completely go away after disabling it, a reboot fixed this issue. There might be another way to do it but I haven't looked into it.

So now for the settings, Microsoft tells you to forward ports [88, 3074, 53, and 80](http://support.xbox.com/en-US/xbox-360/networking/network-ports-used-xbox-live) to your XBOX. It seems they confused incoming and outgoing ports as I only needed to forward port 3074 for the test to pass.

1- Reserve an IP address for the XBOX

2- Forward port 3074: Go to Firewall -> NAT -> Port Forward and add a new rule
{{< thumbnail thumbnail="PortForward-300x253.png" full="PortForward.png" index="0" group="pfsense" >}}
3- Go to Firewall -> NAT -> Outbound and change "General Logging Options" to "Manual Outbound NAT rule generation.(AON - Advanced Outbound NAT)", this is needed to be able to add a the rule below

4- Add a new rule (This should be at the top or the default rule will be matched):

{{< thumbnail thumbnail="NAT-300x214.png" full="NAT.png" index="1" group="pfsense" >}}

The key setting in the screenshot above is "Static port" which will disable the randomization.

**Note:** With the current version of pfSense -2.3.2-RELEASE (amd64)- you will get a "please match the requested format" error when trying to add the NAT rule on Chrome. So use FireFox.