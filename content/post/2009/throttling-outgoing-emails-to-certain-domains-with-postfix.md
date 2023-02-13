---
title: Throttling Outgoing Emails To Certain Domains With Postfix
date: 2009-03-29 11:20:38
categories:
  - Postfix
---

I've been busy setting up a PHPlist server for my employer. All tests went ok, but as soon as we sent our first newsletter Yahoo! blocked the server. After looking around for a solution people suggested we sign all outgoing emails with DomainKeys and not hammer Yahoo's servers with consecutive connection.<!--more-->

Using DomainKeys was a simple setup with DKIMproxy, as for throttling, you all know Postfix is one high performance MTA, so that would be hard to do. PHPlist has a throttling feature but I didn't want to use that because it would slow emails going to all domains and it took about half a day to send messages to about 6,000 users. That is unacceptable.

Update: Yahoo and other providers throttle inbound connections in an attempt to reduce spam. If you're a big operator, talk to them about whitelisting. If not, just wait for the retry, your mail eventually goes through. For bulk mail issues this contact is helpful: <mail-abuse-bulk@cc.yahoo-inc.com>

After some more digging around I found that Postfix 2.5 introduced the perfect solution, here you go:

First, add the following lines to your master.cf

```none
domain1      unix  -       -       n       -       -       smtp
        -o smtp_fallback_relay=
domain2      unix  -       -       n       -       -       smtp
        -o smtp_fallback_relay=
domain3      unix  -       -       n       -       -       smtp
        -o smtp_fallback_relay=
```

Now, to use those transports add these lines to your transport_maps file
```none
domain1.tld    domain1:
domain2.tld    domain2:
domain3.tld    domain3:
```

Finally, set the destination_rate_delay for those transports in main.cf
```none
domain1_destination_rate_delay = 10s
domain2_destination_rate_delay = 20s
domain3_destination_rate_delay = 30s
```

This will effectively send all outgoing messages at full speed, except for messages going to domain1.tld, domain2.tld, and domain3.tld; Postfix will wait 10/20/30 seconds after sending each message to domain1.tld/domain2.tld/domain3.tld.