---
title: "Perl One-liner To Generate htpasswd Passwords"
date: 2014-12-29 01:59:00
categories:
  - Technical
---

**Update:**
An easier way to do it that doesn't require you to install anything special (Works with nginx)
```bash
openssl passwd -apr1
```

Instead of having to install Apache or use an untrusted website just to generate the required password, you can use the following perl one liner
```bash
perl -e 'chomp($password=<>);chomp($salt=`tr -dc A-Za-z0-9 </dev/urandom | head -c 1024`); print crypt($password,$salt)."\n";'
```