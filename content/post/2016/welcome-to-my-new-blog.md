---
title: Welcome To My New Blog
date: 2016-06-14 23:11:28
categories:
  - Technical
---

**Update:** I have since migrated to [Hugo](http://gohugo.io/) which seems to be better maintained and generally easier for me to update. I have also started using [Texts](http://www.texts.io/) more for editing Markdown

I haven't been very active on this blog over the years, one of the reasons was [Wordpress](https://wordpress.org/) itself; As nice as it is, I grew sick of updates always breaking something. Another thing that always made me feel uneasy was the email I got every once and a while from my blog telling me it updated itself. True, this is good when people ignore their blogs but I didn't feel in control of my own blog any more and sometimes I wouldn't have enough time to debug any plugins that broke when the blog decided it was time for me to upgrade.<!--more-->

So after looking around I found [ghost](https://ghost.org/). It seemed like a nice idea so I set up a small server to test it out and managed to import all my Wordpress content without much fuss. ghost allowed me to focus on content and I manged to write more posts in a week than I did the previous year with Wordpress; With wordpress I had to delve in the source of my posts more often than I liked. With [Markdown](https://en.wikipedia.org/wiki/Markdown) I was able to focus on my content which made the experience a lot more enjoyable.

I'm a big fan of [FreeBSD](https://www.freebsd.org/) and use it on almost all servers I manage. When I tried to run ghost on my production server I ran into the issue of getting the node.js web server to automatically start. It took me a couple of hours because for whatever reason the scripts I found online were not working for me.

Once I got that to work and configured nginx as a reverse proxy for my blog, it was time to find a theme. Given the fact that I don't know any useful HTML to make a blog look decent I started looking for anything available for download. Then I was disappointed to find that there hasn't been any update to ghost for some time and that the themes were not as good as I'd hoped.

I ended up checking static site generators and decided to give [Hexo](https://hexo.io/) a try. It was simple enough to get things working and hosting it with nginx was quite trivial. As for content migration I used a slightly modified version of the script available [here](http://caveconfessions.com/ghost-to-hugo/).

I still preferred the Markdown editor that ghost provided and in my search I found [StackEdit](https://stackedit.io/editor) and [Dillinger](http://dillinger.io/) which are even better for my simple needs.

Hopefully I can provide more consistent updates from now on
