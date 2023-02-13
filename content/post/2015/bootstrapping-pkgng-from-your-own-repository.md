---
title: "Bootstrapping PKGNG From Your Own Repository"
date: 2015-03-13 07:47:42
categories:
  - FreeBSD
---

I've been building my own [PKGNG](https://wiki.freebsd.org/pkgng) repositories with [Poudriere](https://github.com/freebsd/poudriere) lately. Some of the benefits include:<!--more-->

- Faster deployment times; You won't have to compile every package and any needed dependencies every time you need them, all updated packages are pre-built the night before
- Conserve bandwidth; All installations happen on the local network, so no need to access the Internet during installation, and packages are only downloaded once
- Compile packages with the options you need; Sometimes you might want to change the default compile options used for packages, e.g. the nginx version available at pkg.FreeBSD.org does not support SPDY, or you might want to remove an option you don't need to minimize the attack surface

To quickly setup your new servers to use your own repository, just add this script to the root of your repository

```bash
#!/bin/sh

# PKGNG bootstrapper
# 20150312, Mohammad Al-Shami

# Use full pathes just in case
PKG=/usr/sbin/pkg
ENV=/usr/bin/env
UNAME=/usr/bin/uname
SED=/usr/bin/sed
MV=/bin/mv
RM=/bin/rm
MKDIR=/bin/mkdir
CAT=/bin/cat

# If for some reason you want to use a different package server
# Send it as a parameter to the script
if [ ! -z $1 ]; then
        pkgServer=$1
else
        pkgServer=192.168.1.150
fi
release=`$UNAME -r | $SED -r "s/([0-9]+).([0-9]+)-RELEASE.*/\1\2x64/"`

export PACKAGESITE=http://$pkgServer/$release-default

# Remove the default FreeBSD repo, only if it exists
if [ -f /etc/pkg/FreeBSD.conf ]; then
        $MV /etc/pkg/FreeBSD.conf /etc/pkg/FreeBSD.conf.org
fi

# Bootstrap pkg
$ENV ASSUME_ALWAYS_YES=YES $PKG bootstrap

# Perform some cleanup
$RM -f /usr/local/etc/pkg.conf

# Set up our repo, which will then be overwritten by Salt
$MKDIR -p /usr/local/etc/pkg/repos/
$CAT > /usr/local/etc/pkg/repos/repositories.conf <<EOF
sauron : {
    url : "pkg+$PACKAGESITE",
    mirror_type : "srv",
    enabled : true,
}
EOF
```

For me, this bootstraps my base repository to allow me to easily install [Salt](http://salt.readthedocs.org/en/latest/) which I then use to manage the repository list.

To bootstrap, just run one the following commands:

```bash
# To you use the default IP address in the script (here it is 192.168.1.150)
fetch http://192.168.1.150/pkgng.sh -o - | sh -
# To use a different IP (If used from a remote site with NAT)
fetch http://repo.mycompany.tld/pkgng.sh -o - | sh -s repo.mycompany.tld -
```
