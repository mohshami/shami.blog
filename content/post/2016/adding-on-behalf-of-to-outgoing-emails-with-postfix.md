---
title: "Adding 'on behalf of' To Outgoing Emails With Postfix"
date: 2016-04-28 13:15:18
categories:
  - Postfix
---

I used to be a big fan of [Mandrill](https://www.mandrillapp.com). I used to use it as an email gateway for my personal servers. It's easy to use and it's cheap (Or free if you send less than 12,000 emails per month). I liked not having to setup [SPF](https://en.wikipedia.org/wiki/Sender_Policy_Framework), [DKIM](https://en.wikipedia.org/wiki/DomainKeys_Identified_Mail), and [DMARC](https://en.wikipedia.org/wiki/DMARC) for my small setups. Even for smaller clients I wouldn't bother with that and just use Mandrill. Emails just show up with the following sender<!--more-->
`USER@XXXXXXXXXX.YYYYY.mandrillapp.com; on behalf of; USER@ORIGINALDOMAIN.TLD`

This was convenient because destination mail servers would check Mandrill's SPF and DKIM instead of checking the sender's.

And then [MailChimp decided to change their business model](http://blog.mailchimp.com/important-changes-to-mandrill/) and Mandrill was no longer an option. I thought about checking other services like [SparkPost](https://www.sparkpost.com/pricing) or [MailGun](https://www.mailgun.com/) but then decided on building my own. You never know when they'd decide to do what MailChimp did.

Just add the following lines to main.cf (Those paths are for FreeBSD, your paths might vary)
```plaintext
sender_canonical_maps = regexp:/usr/local/etc/postfix/canonical
sender_canonical_classes = envelope_sender
header_checks = regexp:/usr/local/etc/postfix/my_custom_header
```

```plaintext
# /usr/local/etc/postfix/canonical
/.*/ user@DOMAIN.TLD
```

```plaintext
# /usr/local/etc/postfix/my_custom_header
/^Subject:/i PREPEND Sender: user@DOMAIN.TLD
```

What this does is add `user@DOMAIN.TLD` as the `Return-Path` of all outgoing emails, and add a `Sender` header to the message. You might want to tweak that logic a bit.
