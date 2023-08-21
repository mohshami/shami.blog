---
title: Solving "Body type not supported by remote host" Under Postfix
date: 2008-03-06 20:43:11
categories:
  - Technical
---

The other day I got some complaints from one of my mail users that he can't send an email to someone. Since I'm the one causing the company to loose money because of my bad servers I had to "fix this issue".<!--more-->

This happens when a mail server -*Usually Microsoft Exchange*- announces it has support for 8BITMIME when you send an EHLO message to it. After it accepts your message, it won't be able to convert it to 7 bit format, then it will email you back with a "Body type not supported by remote host" error.

If you're using Postfix 2.3 or higher this can be easily fixed as follows:

```plaintext
# main.cf:
smtp_discard_ehlo_keyword_maps = hash:/etc/postfix/mta_workarounds
mta_workarounds:
1.2.3.4     8bitmime
```

Our current setup has Postfix 2.2 which does not support smtp_discard_ehlo_keyword_maps and we were not keen on upgrading. You can dump up postfix with "smtp_never_send_ehlo = yes" in main.cf, which will tell postfix not to ask other servers to tell it what features they support, so postfix just uses the minimal requirements for sending emails.

This solution is too crude for my taste, I mean why would you want to dump up Postfix so that a single recipient can benefit, a poorly configured recipient that is.

What you want to do here is dump up Postfix only when it talks to this recipient, here is how:

```plaintext
master.cf:
brokensmtp      unix  -       -       n       -       -       smtp
    -o smtp_never_send_ehlo=yes

transport:
domain.tld        brokensmtp:

main.cf:
transport_maps = hash:path_to_postfix/transport
```

Note the smtp part in the brokensmtp line, not smtpd. This creates a dumped up outgoing thread. You only have to route emails to such recipients through this outgoing thread and you're good.