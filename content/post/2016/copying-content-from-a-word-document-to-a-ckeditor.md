---
title: "Copying Content From A Word Document To A CKEDitor"
date: 2016-05-03 02:42:13
categories:
  - Technical
---

So I've been assisting a customer with their website and I was helping them with some data entry. Most of the content they sent me was in MS Word format. Copying the text directly to Drupal's CKEditor had all formatting messed up so I was copying to notepad, copying from there to Drupal and then formatting manually. This turned out to be a nightmare when I had to copy 10 tables in a single page.<!--more-->

Some Google-fu lead me to the following site

[http://wordtohtml.net/](http://wordtohtml.net/)

Just copied the tables from Word, added `\<\/*p\>|\&nbsp\;` to the `Optional find and replace:` field and most of the work was done for me. I then took the resulting HTML and cleaned it up a bit and then pasted in into Drupal.

**Note:** This didn't work on Firefox, had to use Chrome