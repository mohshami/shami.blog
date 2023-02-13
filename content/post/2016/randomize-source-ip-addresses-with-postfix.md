---
title: "Randomize Source IP Addresses With Postfix"
date: 2016-04-27 09:08:41
categories:
  - Postfix
---

Sometimes when you have a high number of outgoing messages services like Yahoo! and Gmail might block you. To prevent that you need to distribute your outgoing emails through a set of IPs. I used [HAProxy](http://www.haproxy.org/) for that along with a number of [FreeBSD](http://freebsd.org) Jails. That solution is a bit tedious, even though after I started using [Salt](http://saltstack.com) things became a bit easier it was still too complicated for my taste.<!--more-->

Enters [Postfix](http://postfix.org) version 3. It introduced a new [randmap](http://www.postfix.org/DATABASE_README.html#types) table which made this much easier to accomplish.

In main.cf, just add the following lines
```none
sender_dependent_default_transport_maps = 
  randmap:{relay1,relay2,relay3,relay4,relay5}
smtp_connection_cache_on_demand=no
```

Those lines have 2 effects:

* Randomly select an SMTP client for sending each email    
* Prevent the SMTP clients from caching connections, so sending multiple emails to a single domain does not end up using the same SMTP client.

In master.cf, just add new SMTP services and configure them to bind the designated IPs
```none
relay1     unix  -       -       n       -       -       smtp
  -o smtp_bind_address=IP1
  -o smtp_helo_name=foo1.bar.com
  -o syslog_name=relay1
relay2     unix  -       -       n       -       -       smtp
  -o smtp_bind_address=IP2
  -o smtp_helo_name=foo2.bar.com
  -o syslog_name=relay2
relay3     unix  -       -       n       -       -       smtp
  -o smtp_bind_address=IP3
  -o smtp_helo_name=foo3.bar.com
  -o syslog_name=relay3
relay4     unix  -       -       n       -       -       smtp
  -o smtp_bind_address=IP4
  -o smtp_helo_name=foo4.bar.com
  -o syslog_name=relay4
relay5     unix  -       -       n       -       -       smtp
  -o smtp_bind_address=IP5
  -o smtp_helo_name=foo5.bar.com
  -o syslog_name=relay5
```
