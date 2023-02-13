---
date: 2021-06-21T02:38:24-04:00
title: "Detect if your Script is Running in CRON"
---

In my [previous post]({{<relref "back-up-multiple-servers-zxfer.md">}}) I discussed how I use a wrapper script to back up a fleet of servers.<!--more-->

Here I will just post the part about detecting the terminal/CRON, thought this might be useful and worth putting in a separate post making it easier for crawlers to find.

```bash
if [ ! -t 1 ]; then     # We don't have a terminal, then we are in cron
    # Script running in cron, run without output
else
    # Script running interactively, use verbose output
fi
```

This script is POSIX shell compliant so runs everywhere.