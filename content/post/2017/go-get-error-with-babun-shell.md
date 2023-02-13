---
date: 2017-11-21T15:11:55+02:00
title: "Go Get Error With Babun Shell"
---

Quick one here, if you run into the following error when trying to download a go package using [Babun](http://babun.github.io/)

```bash
go get -u -v github.com/cosiner/argv
github.com/cosiner/argv (download)
# cd .; git clone https://github.com/cosiner/argv C:\Users\Mohammad Al-Shami\go\src\github.com\cosiner\argv
Cloning into 'C:\Users\Mohammad Al-Shami\go\src\github.com\cosiner\argv'...
fatal: Invalid path '/cygdrive/c/Users/Mohammad Al-Shami/Desktop/go/C:\Users\Mohammad Al-Shami\go\src\github.com\cosiner\argv': No such file or directory
package github.com/cosiner/argv: exit status 128
```
<!--more-->
This is because Babun comes with it's own version of git which is Unix based and doesn't understand Windows file paths. A simple solution is to use the Windows version of git and give it a higher priority.

```bash
# ~/.zshrc

export PATH=/c/bin/git/bin:$PATH
```

Just restart your shell or source ~/.zshrc and you're ready to go.

Happy development.