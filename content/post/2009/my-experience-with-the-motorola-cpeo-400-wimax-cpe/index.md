---
title: My Experience With The Motorola CPEo 400 Wimax CPE
date: 2009-11-10 11:05:35
categories:
  - Technical
---

Where I live we have no proper DSL (512Kbps max), GSM signals are weak. Sometimes I have to stick my head out of the window just to be able to make a call. Even when I got my Wimax account the indoor CPE kept disconnecting every few minutes. I finally managed to get my hands on an outdoor CPE which made things much better. Typical for someone living at the edge of the world (West Amman).

The Motorola CPEs act as network gateways, they connect to the Wimax network and do NATing for you. That's nice for a home network, less stuff to configure and less clutter.<!--more-->

{{< thumbnail thumbnail="cpeo400.jpg" >}}

The indoor CPE worked well when it had coverage, but when I switched to the CPEo 400 I started running into all sorts of problems; DHCP and DNS stopped working, Connection drops, signal losses, and CPE restarts for no apparent reason.

Calling customer care for a week didn't help, as you know it's useless if your problem is a bit different. Oh believe me, Orange's customer care is much worse, ~~at least with Zain they tell you if they're experiencing technical issues~~ _not really, they both suck_, with Orange it's always your indoor wiring.

Turns out there are some bugs in the OS running on the CPE, I'm assuming it's some sort of Linux distribution gone horribly wrong (Software version 02.01.90-02/11/2009). If you turn on UPnP all Hell breaks loose. I thought I should share this because of the lack of documentation and support for this particular unit.

You have 2 solutions, choose whichever fits your technical skills and/or your time.

Solution 1 (simple): This was the first one I went with, just connect the CPE to the WAN port of your aDSL router. Configure a static IP address and DNS on the router so it won't use the CPE and use that IP as the DMZ. This will have the CPE forward all traffic to the router and have the router handle all the UPnP issues. This, however, you'd end up with double NATing, something not everybody likes.

Solution 2 (A bit technical): Install [dd-wrt](http://www.dd-wrt.com/site/index) on your aDSL router and have it take care of DHCP and DNS, then configure the default gateway as your CPE. You won't have UPnP here but you can set up port forwarding on the CPE which should work fine.

**Update 15/8/2012:** I no longer use this device and I do not recommend using it for anybody. My ISP (Zain Jordan) had very horrible customer support. I have switched to ADSL more than a year ago and would recommend everybody to do the same. Stay away from any ISP that uses this hardware