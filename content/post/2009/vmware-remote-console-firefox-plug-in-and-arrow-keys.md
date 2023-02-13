---
title: VMware Remote Console Firefox Plug-in And Arrow Keys
date: 2009-06-30 09:11:48
categories:
  - Technical
---

VMware remote console was working properly for me when I was using Ubuntu Hardy. After upgrading to Jaunty the arrow keys stopped working inside the remote console. Seems some people face this problem even under windows.<!--more-->

A search got me to [this](http://communities.vmware.com/thread/198779):

```bash
echo xkeymap.nokeycodeMap="TRUE" > ~/.vmware/config
```

Just close any open remote consoles and open up again and you’re in business.