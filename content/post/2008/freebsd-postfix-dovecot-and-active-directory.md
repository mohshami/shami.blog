---
title: 'FreeBSD, Postfix, Dovecot, and Active Directory'
date: 2008-05-25 00:08:00
categories:
  - Technical
description: Setting up an on premise mail server with FreeBSD, Postfix, Dovecot using Microsoft's Active directory as an authentication backend
---

A while back one of my clients had an unpatched qmail server configured with local system users, it was set up in a collocation long before I took over. After having to listen to a lot of complaints about slow internet connectivity I found out that 40-50MB attachments were very common. Another thing I didn't like about this set-up is the fact I had to maintain 2 password databases; An Active Directory for local user login and a shadow file for mail. So a local set-up with Active Directory as a back end was needed.<!--more-->

Postfix comes to the rescue. Having used Postfix for the past 3 years I believe it is the best MTA out there. qmail has it's merits, but I'm not a big fan. After a lot of arguing the client managed to budge and give me one of the old workstations to use as a server, which, a month later had a hard drive crash and I forgot everything about this. Yesterday I thought I should document this since I didn't see an easy to follow HOWTO for doing such a set-up.

**NOTE:** Unless mentioned otherwise, all the samples provided here show the lines you need to change in your configuration files, not the whole contents of those files. Remember to restart each daemon after configuration file changes.

**Update:** After checking vgumus's setup I need to mention this. You'll notice the user part of the email address is the same as the Active Directory user name (mshami and mshami@shami.net). Dovecot expects to get the Active Directory username from Postfix. If you want to use some other address in the “mail” field you have to use the virtual alias maps feature from Postfix to return sAMAccountName.

**Update 2:** This tutorial isn't a substitute for reading the manual pages and having the basic skills to perform these operations. Please consult the manuals to get an idea of the configuration options for each software.

Enough with the introduction, lets get down to business. Here is what we're going to use in order of installation:
- FreeBSD 7.0. You can use Linux if you want, but you have to change a few steps. I'm using the ports version that came on the CD.
- Dovecot 1.0.10
- Postfix 2.4.6

Preparation:
- We will need to have an Active Directory environment set up. This is out of the scope of this document  
- We need a non-privileged user in Active Directory to allow the other programs to authenticate, I'm calling it LDAP, and the password will be qwerty  
- Test username will be mshami and password will be qazxsw  
- Domain name is shami.local  
- Base DN is DC=shami,DC=local  
- IP addresses for our domain controllers are 192.168.192.210 and 192.168.192.211

FreeBSD:
Start your FreeBSD installation, I like to go with minimal installations and then add the needed components. Just make sure to give /usr about 5GB of space and give /var a **LOT** of space to hold the logs and the mail files. Then install the ports collection.

Dovecot:
The first time I did this I used Courier-IMAP. Its a good program but here it has a major issue. You have to create the home directories for all your users before they can log in. I wrote a patch for that but you have to apply it on both the IMAP and the POP3 daemons. You also have to patch Maildrop to do the same. So I decided to go ahead with Dovecot which after some research appears to have better performance than Courier-IMAP and more importantly has self-healing capabilities which solves this issue.

First, add a user called vmail (Assuming UID 1001 and GID 1001), this will be responsible for handling the virtual mailboxes. Then install Dovecot from ports

```bash
cd /usr/ports/mail/dovecot/
make
make install
```

Choose LDAP, LDA, and any other options you want to use, answer yes when asked to create the group and the user dovecot. Asseming UID and GID of 143.

```bash
mkdir /var/vmail
chown vmail:vmail /var/vmail
```

Configuration:
```plaintext
# rc.conf
dovecot_enable="YES"
```

Configure Dovecot:
```plaintext
# dovecot.conf
#We'll be starting with IMAP only, add other protocols when you get your system to start
protocols = imap
#Set all usernames to lowercase before authenticating, because Dovecot will create folders with the mixed case characters.
auth_username_format = %Lu
#Enable non-secure logging for testing
disable_plaintext_auth = no
ssl_disable = yes
#No matter how many domains we have, the usernames will be unique, so save the messages to /var/vmail/username
#Same as default_mail_env
mail_location = maildir:/var/vmail/%n
#Since we have virtual delivery, only the vmail user should be able to deliver, in my case the UID of that user is 1001
first_valid_uid = 1001
last_valid_uid = 1001
#Same thing for groups
first_valid_gid = 1001
last_valid_gid = 1001
#Set this to were you want the messages to reside
valid_chroot_dirs = /var/vmail
#auth default section
##Comment passdb pam
##Commend userdb passwd
##Add ldap passdb and userdb
  passdb ldap {
    # Path for LDAP configuration file, see doc/dovecot-ldap.conf for example
    args = /usr/local/etc/dovecot-ldap.conf
  }
  userdb ldap {
    # Path for LDAP configuration file, see doc/dovecot-ldap.conf for example
    args = /usr/local/etc/dovecot-ldap.conf
  }
```

Set up the LDAP backend:
```plaintext
cp /usr/ports/mail/dovecot/work/dovecot-1.0.10/doc/dovecot-ldap-example.conf /usr/local/etc/dovecot-ldap.conf
vi dovecot-ldap.conf

hosts = 192.168.192.210 192.168.192.211
dn = CN=LDAP User,OU=Special Users,DC=shami,DC=local
dnpass = qwerty
auth_bind = yes
ldap_version = 3
base = dc=shami, dc=local
user_attrs = sAMAccountName=home
user_filter = (&amp;(ObjectClass=person)(sAMAccountName=%u))
pass_filter = (&amp;(ObjectClass=person)(sAMAccountName=%u))
user_global_uid = 1001
user_global_gid = 1001
```

auth_bind tells dovecot to try to bind to Active Directory with the username and password clients authenticate with. Since Active Directory won't let us read the password field then we need to do this. we're not using Kerberos here.

Testing:
```bash
/usr/local/etc/rc.d/dovecot start
telnet localhost 143
Trying 127.0.0.1...
Connected to 127.0.0.1.
Escape character is '^]'.
* OK Dovecot ready.
a LOGIN mshami qazxsw
a OK Logged in.
a EXAMINE INBOX
* FLAGS (Answered Flagged Deleted Seen Draft)
* OK [PERMANENTFLAGS ()] Read-only mailbox.
* 0 EXISTS
* 0 RECENT
* OK [UIDVALIDITY 1206022806] UIDs valid
* OK [UIDNEXT 1] Predicted next UID
a OK [READ-ONLY] Select completed.
a LOGOUT
* BYE Logging out
a OK Logout completed.
Connection closed by foreign host.
```

If you get that then you're OK. Otherwise check your logs. You can turn on debugging in dovecot.conf. Also, you can use the Global Catalog port in your queries. The Global Catalog doesn't use referrals, referrals cause some issues some times.

Now it's time to get SMTP working
```bash
cd /usr/ports/mail/postfix
make
make install
```

Make sure you choose DOVECOT and OPENLDAP. Also choose any other options you need. No need for any Kerberos options. You can use the default options during the make install operation.

Disable sendmail and enable Postfix:
```plaintext
# /etc/rc.conf
postfix_enable="YES"
sendmail_enable="NO"
sendmail_submit_enable="NO"
sendmail_outbound_enable="NO"
sendmail_msp_queue_enable="NO"
 
# /etc/periodic.conf
daily_clean_hoststat_enable="NO"
daily_status_mail_rejects_enable="NO"
daily_status_include_submit_mailq="NO"
daily_submit_queuerun="NO"
```

Fix the Postfix maps
```baSH
postalias /etc/aliases```

Reboot the system for all settings to take effect, then test:
```plaintext
telnet localhost 25
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
220 server ESMTP Postfix
quit
221 2.0.0 Bye
```

Now that Postfix is running, lets hook it up to Active Directory (This is the complete file):
```plaintext
myhostname=mailhost
mydestination=localhost
mynetworks=127.0.0.1
myorigin=shami.net

virtual_mailbox_base = /var/vmail

virtual_uid_maps = static:1001
virtual_gid_maps = static:1001

smtpd_recipient_restrictions = permit_mynetworks, reject_unauth_destination

alias_maps = hash:/etc/aliases
command_directory = /usr/local/sbin
daemon_directory = /usr/local/libexec/postfix

virtual_mailbox_domains =
  shami.net

#LDAP Stuff
virtual_mailbox_maps = ldap:ldapvirtual
ldapvirtual_server_host =
  ldap://192.168.192.210
  ldap://192.168.192.211
ldapvirtual_search_base = DC=shami,DC=local
ldapvirtual_bind = yes
ldapvirtual_bind_dn = SHAMIldap
ldapvirtual_bind_pw = qwerty
ldapvirtual_query_filter = (sAMAccountName=%u)
ldapvirtual_result_attribute = sAMAccountName
ldapvirtual_version = 3
ldapvirtual_chase_referrals = yes
ldapvirtual_result_format=%s/
```

Lets test:
```plaintext
telnet localhost 25
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
220 mailhost ESMTP Postfix
helo localhost
250 mailhost
mail from: mshami@shami.net
250 2.1.0 Ok
rcpt to: mshami@shami.net
250 2.1.5 Ok
data
354 End data with .
hi
.
250 2.0.0 Ok: queued as 92B5911460
quit
221 2.0.0 Bye
Connection closed by foreign host.
```

If all goes well, Postfix will deliver the message to /var/vmail/mshami/

Using the Dovecot LDA:
Normally the virtual delivery agent is enough, but if you want to apply quota or vacation auto reply you're going to have to use the Dovecot LDA. Also, the Dovecot LDA updates the mailbox indexes which will give you better IMAP/POP3 performance

```plaintext

# /usr/local/etc/postfix/master.cf
dovecot   unix  -       n       n       -       -       pipe
    flags=DRhu user=vmail:vmail argv=/usr/local/libexec/dovecot/deliver -d ${user}

# /usr/local/etc/postfix/main.cf
virtual_transport=dovecot
dovecot_destination_recipient_limit=1

# /usr/local/etc/dovecot.conf and uncomment the following (client section removed):
  socket listen {
    master {
      path = /var/run/dovecot/auth-master
      mode = 0600
      user = vmail
      group = vmail
    }
  }
```

Test again:
```plaintext
telnet localhost 25
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
220 mailhost ESMTP Postfix
helo localhost
250 mailhost
mail from: mshami@shami.net
250 2.1.0 Ok
rcpt to: mshami@shami.net
250 2.1.5 Ok
data
354 End data with .
hi
.
250 2.0.0 Ok: queued as 9DBBF1143B
quit
221 2.0.0 Bye
Connection closed by foreign host.
```

Now check your logs, you should see something like this:
```plaintext
postfix/pipe[904]: 9DBBF1143B: to=, relay=dovecot, delay=6.9, delays=6.4/0.01/0/0.56, dsn=2.0.0, status=sent (delivered via dovecot service)
```

Great, now we're ready to enable SMTP authentication:
```plaintext
vi /usr/local/etc/postfix/main.cf
smtpd_sasl_auth_enable = yes
broken_sasl_auth_clients = yes
smtpd_sasl_type = dovecot
smtpd_sasl_path = /var/run/dovecot/auth-client

vi /usr/local/etc/dovecot.conf
  client {
    path = /var/run/dovecot/auth-client
    mode = 0660
    user = postfix
    group = postfix
  }
```

Testing:
```plaintext
telnet localhost 25
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
220 mailhost ESMTP Postfix
ehlo localhost
250-mailhost
250-PIPELINING
250-SIZE 10240000
250-VRFY
250-ETRN
250-AUTH PLAIN
250-AUTH=PLAIN
250-ENHANCEDSTATUSCODES
250-8BITMIME
250 DSN
AUTH PLAIN AG1zaGFtaQBxYXp4c3c=
235 2.0.0 Authentication successful
quit
221 2.0.0 Bye
Connection closed by foreign host.
```

Instead of AG1zaGFtaQBxYXp4c3c= you can generate your own username/password combination by using the command:
```baSH
printf 'usernamepassword' | mmencode```

Where is the null byte.

Enabling quota:
There is no need to go through this here, as the Dovecot wiki explains it clearly.

[http://wiki.dovecot.org/Quota](http://wiki.dovecot.org/Quota)