---
title: Using Your Own Router With The New @orangejo Modem
date: 2014-12-03 12:11:11
categories:
  - Technical
---

**Update:** I have since moved to [Damamax](http://www.damamax.jo) and am **MUCH** happier with their service. Their network is more reliable, faster, and their support staff is wonderful. It's a bit more expensive but considering the advantages I highly recommend switching if they cover your area.<!--more-->

[Orange](https://www.orange.jo) has been pretty much the only option if you wanted to get wired home Internet here in Jordan. Others are starting to come, but for now, Orange is the only one with nation-wide coverage.

{{< thumbnail thumbnail="JEPpJ0Bz1.jpg" >}}

I've had a lot of problems with them in the past, but ever since they switched to [FTTC](http://blog.al-shami.net/2011/08/adsl-in-jordan/ "ADSL in Jordan") the connection has been as advertised. It's stable, fast, and well worth the trouble of installing a land line which is always handy when you need it (**Update**: That applies when communicating with other Orange customers, their International links are not that good, sometimes only delivering 20% of the advertised speed, sometimes even less). If you face an issue you will have to battle with their support staff (They are as bad as support can be; One time they blamed the speed issue of their international links on my home wiring, and someone came to "FIX" the connection only to ruin it and lower my data rate by 50%), but I've found that it's loads better than their competitors; I was a victim of one of their competitors' Wi-MAX service once, the service was not only bad, one of their support staff actually yelled at me during a support call. So you can imagine how happy I was when I finally got connected to the FTTC network.

I've used almost all modems that Orange/JT released since 2004 (even the horrible LiveBox) and my experience with the modem/router combo was never good, even the one I tried from D-Link had its set of limitations and I had to return it a few days later. That's why I have stuck with having my own router and using the modem that Orange provides. Sadly during the first thunderstorm this winter I woke up to a fried modem and had to replace it. When I went to the Orange shop they told me they only carry the new modem/router, so I had to take it.

The new modem/router is much better and is good enough for most people, but not if you:
- Invested money in a router with more powerful Wi-Fi and Gigabit Ethernet
- Use any advanced [router features](http://www.gargoyle-router.com/), e.g.: - All ADSL connections in Jordan are dropped after 24 hours, after which routers redial to go back online, that usually happens at the most inconvenient times and could take up to 3 minutes for the connection to come back (I can't count how many times my connection dropped while I was working on a server upgrade at 3AM), so I set my router to automatically redial the connection at 6:12AM every day (without a reboot), a process that takes 3-5 seconds and mostly goes unnoticed
- My router speaks the API of my [DNS provider](http://www.cloudflare.com/), so I get dynamic DNS with my own domain, for free :)
- Use a VPN for work (Some of my co-workers could not connect to our corporate VPN from home and one time I had same issue at a friend's house)

The options I thought I had were:
- Connect the router to modem and use it as a switch/access point, causing you to lose all advanced features
- Set up the WAN connection as DHCP and NAT for a second time, this is just nasty in my humble opinion

The new modem is a re-branded ZTE ZXHN H108N, some googling revealed that it also works in bridging mode. Bridging is the act of connecting two networks that use different technologies, in our case, the land-line network and the Ethernet.

Configuration is simple, but as with all things IT, take a backup first:

**DISCLAIMER**: I hold no responsibility for any damage this might do to your router, it works for me without any issues, if you proceed you will be doing so at your own risk.

1. Use your browser to navigate to http://192.168.1.1
{{< thumbnail thumbnail="2014-12-03_105505-300x181.jpg" full="2014-12-03_105505.jpg" group="gallery">}}

2. Log in with the username "admin" and the password "admin", no quotes
{{< thumbnail thumbnail="2014-12-03_105546-300x180.jpg" full="2014-12-03_105546.jpg" group="gallery">}}

3. Click on "Network"
{{< thumbnail thumbnail="2014-12-03_105635-283x300.jpg" full="2014-12-03_105635.jpg" group="gallery">}}

4. For all entries in the "Connection Name" list, select the entry and then click "Delete" in the page that loads

5. After you've deleted all entries, select "Create WAN Connection" in the "Connection Name" field

6. Use the following settings
{{< thumbnail thumbnail="2014-12-03_105854-300x245.jpg" full="2014-12-03_105854.jpg" group="gallery">}}

7. Click "Create"

You're done, now you can connect your router to the modem and configure things as you'd do with the old modems