---
title: "Http System Time Update"
date: 2023-08-21T03:56:10-04:00
---

The other day I needed to update the time on a server that didn't have access to any NTP servers. It was a server located in a locked down network with only HTTP/HTTPS access to the internet. I found the following command that allowed me to update the time/date through HTTP

```bash
date -s "$(curl -s --head http://google.com | grep ^Date: | sed 's/Date: //g')"
```
