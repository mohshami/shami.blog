---
date: 2021-09-01T05:46:21-04:00
title: "Expand a Zpool"
---

Block storage volumes are very useful, they give me an easy way of getting ZFS on Ubuntu virtual servers or getting extra storage on FreeBSD. Just attach a volume and create a zpool.

Today one of my volumes ran out of space. So I logged in to my cloud provider and expanded it. Then to expand the zpool I ran the following command

```bash
# zpool online -e ZPOOL_NAME DEVICE
zpool online -e tank da1
```
