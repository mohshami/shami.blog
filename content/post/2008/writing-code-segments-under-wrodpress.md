---
title: Writing Code Segments Under Wrodpress
date: 2008-03-04 10:38:56
---

So yesterday while I was writing the previous post I noticed that WordPress would try to make what I write look more "User Friendly". Well, it works most of the time, but it doesn’t do a good job when it comes to code, it took me a while to get this fixed.<!--more-->

Basically what you need to do is get the [Code Markup](http://wordpress.org/extend/plugins/code-markup/) plugin, activate it, and then enclose the code segment you have in a "code" tag. Also make sure to enclose the "&lt;code&gt;" tag within a "&lt;pre&gt;" tag. For indentation use spaces.

Sample:

```html
<pre><code>This is some code
    Indentation also works
</code></pre>
```