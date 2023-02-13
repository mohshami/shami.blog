---
title: "Recursively Upgrade Package Dependencies With pkgng"
date: 2014-11-11 12:05:36
categories:
  - FreeBSD
---

**Update:** I now just use `pkg upgrade` since I have better control over my package repo and it is a much better way to upgrade.<!--more-->

I've been hosting my own [pkgng](https://wiki.freebsd.org/pkgng) repository for a few months and loving it. One thing I've had problems with was upgrading package dependencies. For example, I would find myself upgrading [Salt](http://www.saltstack.com/community/) without upgrading [ZMQ](http://zeromq.org/) which led to lots of issues.

To upgrade a package and all its dependencies, run the following command

```bash
pkg info -d PKG_TO_UPGRADE | awk -F'-' '{for (i=1;i&lt;NF-1;i++) { printf $i FS } print $i NL }' | xargs pkg install -y
```

What this does is get a list of package dependencies from pkgng, run them through awk to remove version numbers, then xargs runs the pkg install command on all packages.
