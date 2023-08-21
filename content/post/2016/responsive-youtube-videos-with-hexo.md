---
title: "Responsive Youtube Videos With Hexo"
categories:
  - Technical
date: "2016-09-27 14:05:00"
---

**Update:** I have since moved to [Hugo](https://gohugo.io) with [Tailwind CSS](https://tailwindcss.com/) and not sure if this code is still valid.

So now that I have finally finished fixing my content migration issues I can get back to writing.

While checking my old posts I noticed embedded using the &#123;% youtube %&#125; tag looked like this:<!--more-->

<p><div class="video-container"><iframe src="//www.youtube.com/embed/tcG_15pkIkc" frameborder="0" allowfullscreen></iframe></div></p>

To solve this, I changed /node_modules/hexo/lib/plugins/tag/youtube.js and replaced the return line with

```plaintext
return '&lt;style&gt;.codegena{position:relative;width:100%;height:0;padding-bottom:56.27198%;}.codegena iframe{position:absolute;top:0;left:0;width:100%;height:100%;}&lt;/style&gt;&lt;div class="codegena"&gt;&lt;iframe width="500" height="294" src="https://www.youtube.com/embed/' + id + '?&autohide=2"frameborder="0"&gt;&lt;/iframe&gt;&lt;/div&gt;';
```

Now videos look much better

<p><style>.codegena{position:relative;width:100%;height:0;padding-bottom:56.27198%;}.codegena iframe{position:absolute;top:0;left:0;width:100%;height:100%;}</style><div class="codegena"><iframe width="500" height="294" src="https://www.youtube.com/embed/tcG_15pkIkc?&autohide=2" frameborder="0"></iframe></div></p>
