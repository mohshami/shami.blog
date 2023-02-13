---
title: Cleaning Up Your Boot Partition With Ubuntu
date: 2009-12-25 15:20:51
categories: 
  - Linux
---

If you haven't reinstalled Ubuntu in a while, the /boot partition will eventually fill up with all the updated kernels, and you'll get an error when trying update.<!--more-->

At first I used to uninstall the old kernels manually but being lazy I think it's too much work. When you get the error with update-manager or Synaptic try this:

```bash
sudo aptitude search linux -w 160 | egrep '(image|headers|restricted)' | egrep '^i' | grep -v 'KERNEL_VERSION' | grep -v -P '[^d]-generic' | grep -v linux-restricted-modules-common | sed 's/i A/i  /' | awk '{print $2}' | xargs sudo aptitude remove
```

Replace "KERNEL_VERSION" with your currently running kernel.

This might break your grub configuration but update-manager will fix that for you so no need to worry. Just make sure you run this BEFORE update-manager does the update.

To be honest I didn't try this without "grep -v ‘KERNEL_VERSION" so I'm not sure if removing it would break something. Just leave it there to be safe.