---
title: Delete All Messages From A POP3 Account
date: 2010-04-21 12:52:54
categories:
  - Technical
---

Here at the office, we host a few domains with [Verio](http://www.verio.com/). Not my choice, and I'm not happy with it. We also host some mailboxes for one of those domains with Verio. I got a message from Verio support saying the mailboxes for that domain are occupying around 1GB of space, and that we need to delete some of them.<!--more-->

Turns out the mailboxes were neglected for months, and one of those mailboxes got around 55,000 messages.

Simple enough, I said, let's log in to web mail, keep recent relevant messages and delete the rest. But the web mail interface kept timing out, and I couldn't access any of the accounts. Seems they built their own web mail interface, which tries to load everything in your mailbox. This makes it time out when a mailbox has this huge number of messages.

After contacting Verio's support they gave me an IP address to use as an IMAP server, which, surprisingly (well, not really, I expected it) wouldn't connect. After a few days of deliberation the department in charge of the accounts decided to delete all messages in all accounts.

At first I configured Evolution to download all messages from POP3, which thankfully worked (Thanks Dovecot), but that took too long, and downloading 50K messages would overload our uplink. A simple solution would be as follows:

```python
#!/usr/bin/python

import poplib

server = 'server'
user = 'user'
password = 'password'

whenToQuit = 500
loop = 0
totalMessages = 0

while 1:
        M = poplib.POP3(server)
        M.user(user)
        M.pass_(password)
        numMessages = len(M.list()[1])
        if totalMessages == 0: totalMessages = numMessages
        i = 0
        for i in range(numMessages):
                print 'Deleted %d out of %d messages' % (loop * whenToQuit + i + 1, totalMessages)
                M.dele(i+1)
                if i == whenToQuit - 1:
                        M.quit()
                        loop = loop + 1
                        break

        if i != whenToQuit - 1:
                M.quit()
                break
```

Since the actual deletion of messages happens when a client “quit”s, I wrote this to do a quit after 500 message, this will enable you to quit the script after some time without having to lose all the progress.

Hope this helps.