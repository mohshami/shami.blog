---
title: First Thoughts of @ZainJo's HSPA+ Service
date: 2011-04-05 23:18:27
categories:
  - Technical
---

Lately ISPs have been bombarding us with all sorts of Internet related ads, promising "high speeds" or "unlimited downloads". Osama Hajjaj said it best with this comic:<!--more-->

{{< thumbnail thumbnail="comic.jpg" >}}

I want to get a few things straight before we move on
- Since what you're paying for is essentially shared bandwidth, it can never be "unlimited". ISPs need to make money as well, so they can't let you hog their bandwidth, but in the case of ADSL, unlimited downloads during the night is possible because most users are asleep, and those few heavy downloaders won't affect the mostly un-utilized ISP uplink
- For the same reason as above, what ISPs are advertising is a best case scenario, so there are times when you will be facing slowdowns. Reasons for slowdowns differ for each technology used. With wired being superior to wireless.
- A respectable ISP will minimize those slowdowns as much as possible. Zain failed in this respect with WiMAX, let's hope the same doesn't happen to their HSPA+ service
- ISPs try to sell a lot of corporate bandwidth, which is very profitable, then try to use that bandwidth during the night for residential users to minimize costs.

A question raises itself, do we really need all this speed? The FCC defines "broadband" as having 4Mbps or more, looking at the Jordanian market, most people are below 1Mbps, so maybe 80% do not have broadband. Another question raises itself, does it really matter? No, for most people anyways.

Let's look at how Jordanians use the Internet, most people only use it for browsing, email, the occasional photo sharing, and in rare cases, video streaming.

Even for the pickiest of users, the difference in speed is only noticeable up to the 2Mbps mark, the above uses will not change the experience for anybody. Most websites are not properly built so they're slow, and video streaming (for standard definition) will buffer faster than playback speed, so it won't be of any benefit to the user. Even for those who use the lower speeds, they don't really care.

Why then, you ask, do we need "proper" high speed Internet? The answer is simple, downloads. If you've ever waited on a file you need for work to finish downloading, you'll realize why high speed is nice to have. I personally download a lot of ISO images to test numerous system configurations, I also download the actual programs to perform the required testing. Having to wait 15 minutes for a 70MB file is never good. I had to switch from FreeBSD to Ubuntu Linux for my prototyping needs because Ubuntu requires much less downloading. If I had 8Mbps (Been 3 weeks since I paid Orange for an 8Mbps account, which I'm still waiting for) instead of my current 1Mbps the download would take about 2 minutes, which is OK by all standards. If you download TV shows or movies, the problem becomes even worse; A 20 minute HD video is about 650MB, that's a 3 hour download on a 1Mbps connection, with 8Mbps, that's 20 minutes, a BIG difference.

Up until recently, there were no cheap Internet connectivity options. Or let me rephrase, no cheap "decent" connectivity options. 13JDs for a 128Kbps is not considered cheap, for an option to be considered cheap in Jordan, it'll have to cost around 5-10JDs a month and it definitely has to be faster than 128Kbps to allow the occasional Youtube streaming without having to buffer for 15 minutes. For those who only used 2GB a month (yes, those people exist), they had to pay 30+JDs for 10-15GB which they never used.

After the introduction of WiMAX back in 2007, prices went down, but not much. Orange still had dominance over the market for 2 reasons; They were the only company that bought bandwidth from international ISPs, and their networks were far superior to WiMAX given the fact it's wired, so the others were unable to match Orange on terms of speed. Not to mention that Orange's network has been here for ages, which allowed them to upgrade it while still making money, which cannot be said about the others.

Now comes the primary reason for this post, Zain's HSPA+. Now that Zain has come with a somewhat reasonable alternative, which had various options depending on your usage levels. Starting from 6JD for 1GB up to 49JDs for 30GB. Those should suffice the needs of about 97% of Jordanians.

{{< thumbnail thumbnail="dongle.png" >}}

I was given a 1 month subscription along with a 21Mbps dongle, the Huawei E367, which was surprisingly Linux compatible. Zain gets extra points for this particular selection.

The frequency used by HSPA+ is higher than GSM, which means GSM has better signal penetration. In my house, I can barely make voice calls. So when my phone barely picked up the signal I wasn't surprised. I thought the dongle would have better reception than the phone, sadly that wasn't the case. But if you look at any wireless technology, those don't really work with the buildings we have in Jordan. If you have heat insulation you will most probably not get any good signal indoors.

When Zain first released the service I faced a lot of dropped calls and broken messages, but I haven't faced them as much lately, I guess this comes with being an early adapter. I do however keep my phone on GSM most of the time to make the battery last longer, and to make use of GSM's better coverage.

To do some testing, I took the laptop to the roof and tried to connect, sadly I only got 2 bars, very disappointing, but that gave me about 4Mbps download (no screenshot for this one folks, sorry).

Then I went to a coffee shop in Swiefeyyeh to try it out, 2 bars as well. I also assume this is because the network isn't a 100% ready, so hopefully it'll be better in a month or 2., but this time I got
{{< thumbnail thumbnail="1236190213.png" >}}
Good, but still not as good as the advertised 21Mbps, I assume this is because Zain's network is still new, and you'll need to have a full signal to at least have a chance of getting the full speed. Downloading from a dedicated server gave me about 900-950KB/s, very good.

Then on the way home I bought a USB extension cable, upon arriving to my desk, I connected the dongle to my laptop using the cable, and threw the dongle out of the window, this time I got 2 bars, and the following speed:

{{< thumbnail thumbnail="1236328367.png" >}}

Now for the most important usage of this connection, browsing. To be honest, I was very disappointed at first, because page load times were not that of connections that get the speeds above. After a few minutes I changed the DNS settings on my connection to Google's 8.8.8.8 servers and browsing was much better afterwards.

I've noticed that Zains' DNS servers have been slow ever since WiMAX, they use BIND which is one of the most popular DNS servers on the Internet, I assume they're running it on some Linux distribution. I'm not a big fan of that particular setup. If someone at Zain reads this, please try using NSD for authoritative servers and Unbound for your caching servers, also try installing them on FreeBSD, which has a much better TCP/IP stack implementation.

Youtube was slower than I expected, but still fast enough, although I didn't try watching HD video, so your mileage may vary. I also noticed the dongle becomes warm after some time, wasn't very impressed with that.

OK, to the conclusion, is this worth buying? For me, it was a bit underwhelming, but for a lot of people, they'll find it does the job. I would stay away from it if there a is commitment involved, but if you can cancel your contract if Zain starts messing up then by all means try it. No commitment means Zain has to keep the service working well to keep the customers.

For people like me who download a lot, I say stick with DSL, it's still a better option. Given the fact it's not very good indoors, at least in my house, I wouldn't bother with it for anything other than a secondary connection when at clients, if it actually works.

My personal experience with Zain is that the service will be great at the beginning, but then the network will get congested and they won't bother upgrading. Let's hope the same doesn't happen with HSPA+. Note however that their network is very young, and they have built it in record time. So facing these issues at this time is normal, let's hope they make it better, not worse.

Oh, and if you get it, make sure you don't deplete your download quota, and check it frequently. If you end up using a lot it will be VERY expensive.