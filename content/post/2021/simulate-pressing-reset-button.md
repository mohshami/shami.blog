---
date: 2021-06-03T00:12:14-04:00
title: "Simulate Pressing the Reset Button"
---

We've all been there, something gets stuck and there is no way to fix it except for a reboot, but even rebooting through SSH isn't working and you don't have physical access to the server or an out-of-bound way to power cycle. This has mostly bit me while working on NFS but there has been other cases. Adding it here for reference.<!--more-->

### Disclaimer
***Doing this might result in data loss. The commands below cause an instant power cycle similar to pressing the reset switch or unplugging/replugging the power cord. Any dirty buffers will not be saved to disk. Do not use unless you absolutely have to and know what you are doing.***

For FreeBSD:
```bash
sysctl debug.kdb.panic=1
```

For Linux:
```bash
echo b > /proc/sysrq-trigger

# Some documentation mentions you need to enable sysrq first, but it was never the case for me
# Adding it here for reference
echo 1 > /proc/sys/kernel/sysrq
```