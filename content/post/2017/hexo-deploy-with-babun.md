---
date: "2017-03-28"
title: "Hexo Deploy With Babun"
---

I have recently switched to [Babun](http://babun.github.io/). It's, IMHO, the best Windows shell so far. Combine it with [TidyTabs](http://www.nurgo-software.com/products/tidytabs) and you have a very nice solution. But I was unable to get hexo deployment to work well with it so I had to use git bash. git bash would show a popup asking for my SSH key password while Babun wouldn't.

I found the solution [here](https://github.com/babun/babun/issues/290), just enable the SSH-agent plugin in zsh

```css
# ~/.zshrc
plugins=(git, ssh-agent)
```

You will just be prompted for the password of your SSH key when you start Babun.
<!--more-->