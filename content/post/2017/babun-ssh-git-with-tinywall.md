---
date: 2017-09-06T16:17:20+03:00
title: "Babun SSH/Git With TinyWall"
---

I was thinking of a way to make my laptop a bit more secure and started looking into alternative firewalls for Windows. I came across [TinyWall](https://tinywall.pados.hu/) which is an alternative front end to the Windows firewall so it's not as intrusive as the other options. Everything was working well till I tried to pull a git repository from [Babun](http://babun.github.io/) and I got an the following error<!--more-->

```none
ssh: connect to host bitbucket.org port 22: Network is unreachable
```

The solution was simple, just whitelist the following EXEs

- %USERPROFILE%\\.babun\cygwin\bin\git.exe
- %USERPROFILE%\\.babun\cygwin\bin\sh.exe
- %USERPROFILE%\\.babun\cygwin\bin\ssh.exe

That's assuming you used the default installation path