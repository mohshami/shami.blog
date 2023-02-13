---
date: 2017-04-21T13:56:17+03:00
title: Use Just What You Need Out Of Bootstrap And Similar Frameworks
categories:
  - Technical
---

If you know me, you'll know I'm obsessed with speed. I like websites that are light and load quickly. At first I used [WordPress](https://wordpress.org/) because I knew how to optimize it and make it load quickly. I also used the [GeneratePress](https://generatepress.com/) theme because I loved how quickly it loaded. You can read [this post](/2016/06/welcome-to-my-new-blog/) to see why I migrated away.

Ghost introduced me to [Markdown](https://en.wikipedia.org/wiki/Markdown) and I could never look back, but since I didn't find any themes that I liked and the fact that Ghost looked as if it hadn't been maintained in a while lead me to look for alternatives.<!--more-->

During my search I stumbled on static site generators like [Jekyll](http://jekyllrb.com/) and [Hexo](https://hexo.io/). They fit my use-case perfectly; A simple site that is infrequently updated. So I went with Hexo. I asked a friend of mine to clone GeneratePress since I didn't know any useful HTML/CSS to be able to do so myself. My first requirement was not to use [Bootstrap](http://getbootstrap.com/) as I found it too big and would slow my blog.

Now that I finally got myself to learn HTML/CSS, I decided to build another GeneratePress clone myself since it's simple enough, and in the meantime give [Hugo](https://gohugo.io/) a try. The result is the blog you see here :)

So enough with the introduction. I used Yahoo's [Pure.css](https://purecss.io/) since it felt light and easy enough for me to use. I tried other libraries but this was the one that just clicked.

After showing the result to two of my web developer friends (who are very capable and knowledgeable by the way), they told me about Sass and the fact I could get only a subset of Bootstrap to build a lightweight and battle-tested website. I had heard of Sass before but I never looked at it since I'm very new to CSS, I thought I would first learn vanilla CSS and then move on to Sass if I had the time.

I took a look [here](http://getbootstrap.com/customize/) and found you can indeed customize Bootstrap to your needs, but doing so every time felt too much work, what if I needed an extra component? You'd have to download again. So I started looking for a way to do it with Sass, because why not? :)

After some searching I found [this wonderful article](https://jonathanmh.com/bootstrap-4-grid-only-and-sass-with-gulp/), which I'm basing my post on. In my case this is not a big difference, but when applied to a library like Bootstrap it will, and I also wanted to share my workflow

The tools I'll be using

-   Pure.css

-   [Prepros](https://prepros.io/), you can download it for free, it will just nag you to buy. It will watch your Sass files and compile them on the fly

-   A code editor

My theme had the following

```html
<link rel="stylesheet" href="https://unpkg.com/purecss@0.6.2/build/pure-min.css">
<link rel="stylesheet" href="/css/style.css">
<link rel="stylesheet" href="/css/lightbox.css">
<link rel="stylesheet" href="/css/prism.css">
<link rel="stylesheet" href="/css/grids-responsive-min.css">
```

```html
<script src="/js/lightbox.js"></script>
<script src="/js/prism.js"></script>
<script src="/js/lazyload.transpiled.min.js"></script>
```

All of the above was downloaded except for style.css, which I wrote.

Convert style.css to Sass:
--------------------------

That wasn't hard as the file was quite simple.

Concatenate and minify javascript files:
----------------------------------------

Using Prepros, create a new .js file and put the following content

```none
//@prepros-append lazyload.transpiled.min.js
//@prepros-append lightbox.js
//@prepros-append prism.js
```

The output file will contain all javascript code minified. The resulting html becomes

```html
<script src="/js/main.js"></script>
```

Minimizing CSS:
---------------

This is the part inspired by the article above. I cloned the [Sass version](https://github.com/rubysamurai/purecss-sass.git) of Pure.css and added the following to the beginning of my style.scss. Of course you will have to move your original CSS files from /css to /css-full and rename them as below

```sass
@import "../purecss-sass/vendor/assets/stylesheets/purecss/_base.scss";
@import "../purecss-sass/vendor/assets/stylesheets/purecss/_grids.scss";
@import "../purecss-sass/vendor/assets/stylesheets/purecss/_grids-responsive.scss";

@import "../css-full/_lightbox.scss";
@import "../css-full/_prism.scss";
```

Then changed the html to

```html
<link rel="stylesheet" href="/css/main.css">
```

Those changes made my CSS (uncompressed) go from 38KB to 25KB.
