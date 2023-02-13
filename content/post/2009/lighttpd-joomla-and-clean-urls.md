---
title: 'Lighttpd, Joomla, And Clean URLs'
date: 2009-06-22 13:48:26
categories:
  - Technical
---

So I'm working on a new web server but I don't want to use Apache since it's a virtual machine. Had some trouble with the rewirte rules but I think I got them<!--more-->

From [this forum post](http://forum.joomla.org/viewtopic.php?f=433&p=1390643)

```none
$HTTP["url"] !~ ".(gif|png|css|jpg|jpeg|js)$" {
   server.error-handler-404 = "/index.php"
}
```

But I thought of a different approach and it seems to work so far, and maybe causes less error messages in the logs:

```none
url.rewrite-once = ("^/(.*.html)$" => "/index.php?page=$1", "^/(.*.html?.*)" => "/index.php?page=$1", "^/(.*/?.*)" => "/index.php?page=$1")
```

Have a good one