---
title: "Using The @ZainJo HSPA Dongle With Ubuntu Linux"
date: 2011-04-04 22:35:17
categories:
  - Linux
---

After my experience with Zain's WiMAX, I didn't think I'd be using their service again. But Zain gave me a 21Mbps dongle (The Huawei E367) for free as to see how much better the new service is and I thought I might as well try it. I'll be writing on my experience with the service in a separate post inshalla.<!--more-->

~~I'm~~ _I used to be_ a big Ubuntu fan and been using it as my primary desktop since 2007 _(Not anymore)_, and Linux compatibility has always been absent in the mobile Internet world. I wasn't gonna switch my primary OS just to use a USB dongle.

After plugging it in nothing happened, didn't see a notice on the screen, no pop-pups or anything to show that something happened. After a quick lsusb I found this:

Bus 002 Device 005: ID 12d1:14ac Huawei Technologies Co., Ltd.

Kudos Huawei on showing us Linux users some love. Zain gets extra points for this choice.

Ok let's get this bad boy configured. I got the settings from Zain's Windows application. The following was done on Ubuntu 10.10, other distributions might vary.

1. If the dongle was unplugged when you booted your computer, restart Network Manager `sudo service network-manager restart`, wait a few seconds, then right click the Network Manager icon and choose "Edit Connections..."
{{< thumbnail thumbnail="Screenshot-1.png" >}}
2. Go to the "Mobile Broadband" tab and click "Add" (You will not see "Zain Jordan" on your screen)
{{< thumbnail thumbnail="Screenshot-2.png" >}}
3) The following screen will show up, if you didn't restart Network Manager you will not see the Huawei modem, click "Forward"
{{< thumbnail thumbnail="Screenshot-3.png" >}}
4) Choose "United States" then click "Forward", don't bother looking for Jordan, you won't find it
{{< thumbnail thumbnail="Screenshot-4.png" >}}
5) Choose "I can't find my provider and I wish to enter it manually", then enter any name you desire, I chose "Zain Jordan"
{{< thumbnail thumbnail="Screenshot-5.png" >}}
6) Choose "My plan is not listed..." and for "Selected plan APN (Access Point Name)" enter "zain", all lower case letters, without the quotes, then click "Forward"
{{< thumbnail thumbnail="Screenshot-6.png" >}}
7) Click "Apply"
{{< thumbnail thumbnail="Screenshot-7.png" >}}
8 ) The following window appears, don't change anything except "Username" and "Password", set them to "Zain", all lower case except for the Z, then click on "Apply"
{{< thumbnail thumbnail="Screenshot-8.png" >}}
9) You're all set, to connect, left click on your Network Manager icon and choose your connection name
{{< thumbnail thumbnail="Screenshot-9.png" >}}
If you face any issues, just remove the dongle, reconnect, then restart Network Manager.
