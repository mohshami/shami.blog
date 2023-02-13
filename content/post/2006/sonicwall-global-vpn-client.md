---
title: "Sonicwall Global VPN Client"
date: 2006-10-30 10:30:00
categories:
  - Technical
---

Last week while I was going over a checklist on a client's system when our Leased Line service was disconnected.

No worries, that happens some times. I wait for the connection to go back up so I can finish my work, but I could not connect to the client's network after that happened. So I think to myself, maybe the firewall still had the connection opened, so I go about and restart the firewall -which is a Sonicwall tz170 btw.<!--more-->

That also didn't work, so I search the web looking for an answer, but to no avail. Today, our Windows admin Ziad told me that he found a solution to this problem, and I decided to share it.

He came across this solution by chance, what he basically did is:

1. Set up the network adapter to use a static IP address
2. Removed the reservation from the server DHCP server
3. Stopped the DHCP client service (when I tried this I disabled it all together)
4. Rebooted the machine
5. Set up the network adapter to use DHCP
6. Here I turned on the DHCP service
7. Open Sonicwall VPN client
8. Delete the connection and create it back again

That fixed it for both of us. It seems that the routing table for this stupid piece of software was corrupted or something

Hope this helps someone out there. Have a nice day  

Shami