---
title: 'HOWTO: Small Mail Server With Salt, Dovecot, And OpenSMTPD'
date: 2015-01-26 17:25:10
categories:
  - Technical
---

**Update:** Sadly OpenSMTPD version 5.4.4 on FreeBSD broke the passwd table, I'm checking the Gills to get this fixed.

**Update2:** I am no longer using OpenSMTPD. I've switched to [dma](https://wiki.mageia.org/en/Dma_Dragonfly_Mail_Agent) for servers that only need to send emails and went back to Postfix for servers that require an actual MTA. Not that OpenSMTPD is bad, I just prefer Postfix. I might reconcider in the future when OpenSMTPD is more mature.<!--more-->

I'm a big fan of [Postfix](http://www.postfix.org/) and have been using it for years, but also find it to be an overkill for some of my servers. I don't want to have to install Postfix on my DNS management server just to send change notifications. Sendmail was good for that for a while, but I hated the configuration language. Then I read that the OpenBSD maintainers switched to [OpenSMTPD](https://www.opensmtpd.org/) as their default MTA, so I decided to give it a shot.

It turned out to be a very nice piece of software; Small, fast, stable, and very easy to customize, no more ugly m4 macros to deal with :D. Now I have a [Salt](http://salt.readthedocs.org/en/latest/) [formula](https://github.com/mohshami/salt_formulas) that installs OpenSMTPD, configures it to auto-start, and disables Sendmail. I use that for all non-mail servers for report and notification emails.

Then I decided to start using OpenSMTPD on some of our smaller mail servers; We have a small [PHPList](https://www.phplist.com/) server so I decided to start with that.

This configuration is targeted towards smaller mail servers, if you have a few accounts you can host this configuration on a small VPS. You don't have to use a Salt master, you can simply use a masterless setup. Why Salt? Because the configuration uses static files to store usernames and passwords but OpenSMTPD and Dovecot can't share those files. You're welcome to maintain those files by hand, but I think it's too much of a hassle.

I use FreeBSD so the configuration files reflect that, change to fit your own setup.

First, install the needed software
```bash
pkg install dovecot2 opensmtpd py27-salt dkimproxy
```

Enable Salt masterless mode if you need to, otherwise configure Salt as you normally do
```bash
cd /usr/local/etc/salt
cp minion.sample minion
```

Change the file_client to local
```yaml
file_client: local
```

Now lets get to the configuration files. Full configuration is hosted on [GitHub](https://github.com/mohshami/salt_dovecot_opensmtpd)

**Custom Salt modules:** Copy to states/_modules inside your salt directory:
This module hashes the given plain text passwords, and uses a random password salt if none was provided

password.py:
```python
import crypt
import os

def hash(pw, salt=None):
	if not salt:
		salt = os.urandom(16).encode('base_64')

	salt = "$6${}$".format(salt)

	return crypt.crypt(str(pw), salt)
```

This module generates the private key and the zone file entry to be used with BIND/NSD for the DKIM key

dkim.py:
```python
def generate(bits=1024):
	'''
	Generate an RSA keypair with an exponent of 65537 in PEM format
	param: bits The key length in bits
	Return private key and public key
	'''
	
	from Crypto.PublicKey import RSA
	new_key = RSA.generate(bits, e=65537)

	public_key = str(new_key.publickey().exportKey("PEM"))
	public_key = public_key.replace('-----BEGIN PUBLIC KEY-----', '')
	public_key = public_key.replace('-----END PUBLIC KEY-----', '')
	public_key = public_key.replace('\n', '')

	private_key = str(new_key.exportKey("PEM"))

	return [private_key, public_key]
```

**Pillar files:** Here we store all domains, accounts and passwords

top.sls:
```yaml
base:
  '*':
    - mail.users
```

Here, salt is the password salt used to encrypt the passwords. It's not related to the configuration manager

mail/users.sls:
```yaml
salt: aoiuasdfhalsdfiuyh

domains:
  - example.com
  - test.com

accounts:
  - 
    - user1@example.com
    - pass1
  -
    - users2@example.com
    - pass2
  -
    - users3@test.com
    - pass3
```

**State files:** Configure Dovecot, openSMTPD and DKIMProxy

top.sls:
```yaml
base:
  '*':
    - mailsrv.genkeys
    - mailsrv.opensmtpd
    - mailsrv.dovecot
    - mailsrv.dkimproxy
```

Dovecot:

mailsrv/dovecot.sls:
```yaml
dovecot:
  service:
    - running
    - reload: True
    - watch:
      - file: /usr/local/etc/dovecot/dovecot-passwd
      - file: /usr/local/etc/dovecot/dovecot.conf

/usr/local/etc/dovecot:
  file.directory:
    - makedirs: True

/usr/local/etc/dovecot/dovecot-passwd:
  file.managed:
    - source: salt://mailsrv/conf/dovecot/dovecot-passwd
    - template: jinja
    - require:
      - file: /usr/local/etc/dovecot

/usr/local/etc/dovecot/dovecot.conf:
  file.managed:
    - source: salt://mailsrv/conf/dovecot/dovecot.conf
    - require:
      - file: /usr/local/etc/dovecot
```

mailsrv/conf/dovecot/dovecot.conf:
```none
protocols = imap pop3 lmtp

log_path = /var/log/dovecot.log

# SSL configuration
ssl = yes
# Preferred permissions: root:root 0444
ssl_cert = &lt;/usr/local/etc/mail/cert/cert
# Preferred permissions: root:root 0400
ssl_key = &lt;/usr/local/etc/mail/cert/key

mail_location = mdbox:~/mdbox

passdb {
	driver = passwd-file
	args = /usr/local/etc/dovecot/dovecot-passwd
}

userdb {
	driver = static
	args = uid=vmail gid=vmail home=/vmail/%d/%n
}

service lmtp {
	inet_listener lmtp {
		address = 127.0.0.1
		port = 2525
	}

	#This is here to handle high traffic
	process_min_avail = 10
}

#Private name space, allows each user to access their mailbox
namespace {
  type = private
  separator = /
  prefix =
  location =
  inbox = yes
}
```

mailsrv/conf/dovecot/dovecot-passwd:
```none
{% raw %}{% set passwordSalt = salt['pillar.get']('salt') %}
{%- for account in salt['pillar.get']('accounts') -%}
{{ account[0] }}:{SHA512-CRYPT}{{ salt['password.hash'](account[1], passwordSalt) }}
{% endfor -%}{% endraw %}
```

OpenSMTPD:

mailsrv/opensmtpd.sls
```yaml
smtpd:
  service:
    - running
    - watch:
      - file: /usr/local/etc/mail/vdomains
      - file: /usr/local/etc/mail/recipients
      - file: /usr/local/etc/mail/passwd
      - file: /usr/local/etc/mail/smtpd.conf
      - file: /usr/local/etc/mail/cert

/usr/local/etc/mail:
  file.directory:
    - makedirs: True

/usr/local/etc/mail/vdomains:
  file.managed:
    - source: salt://mailsrv/conf/opensmtpd/vdomains
    - template: jinja
    - require:
      - file: /usr/local/etc/mail

/usr/local/etc/mail/recipients:
  file.managed:
    - source: salt://mailsrv/conf/opensmtpd/recipients
    - template: jinja
    - require:
      - file: /usr/local/etc/mail

/usr/local/etc/mail/passwd:
  file.managed:
    - source: salt://mailsrv/conf/opensmtpd/passwd
    - template: jinja
    - require:
      - file: /usr/local/etc/mail

/usr/local/etc/mail/smtpd.conf:
  file.managed:
    - source: salt://mailsrv/conf/opensmtpd/smtpd.conf
    - require:
      - file: /usr/local/etc/mail

/usr/local/etc/mail/cert:
  file.recurse:
    - source: salt://mailsrv/conf/opensmtpd/cert
    - user: root
    - group: wheel
    - file_mode: 600
    - dir_mode: 700
    - require:
      - file: /usr/local/etc/mail
```

Use relay instead of deliver because OpenSMTPD requires a local user account to deliver, this way we can use virtual accounts with Dovecot 

mailsrv/conf/opensmtpd/smtpd.conf:
```none
#PKI file locations
pki mailsrv.example.com certificate "/usr/local/etc/mail/cert/cert"
pki mailsrv.example.com key "/usr/local/etc/mail/cert/key"

# Accept email for these domains and recipients
table vdomains "file:/usr/local/etc/mail/vdomains"
table recipients "file:/usr/local/etc/mail/recipients"

# If you edit the file, you have to run "smtpctl update table aliases"
table aliases file:/etc/mail/aliases

# File where encrypted passwords are stored
table local_user_list passwd:/usr/local/etc/mail/passwd

# Listen for user logins on submission port
listen on 0.0.0.0 port submission tls pki mailsrv.example.com auth &lt;local_user_list&gt; hostname "mailsrv.example.com"

# To accept external mail
listen on 0.0.0.0

# Accept signed emails
listen on localhost port 10028 tag DKIM mask-source

# Forward incoming emails to Dovecot via LMTP
accept from any for domain &lt;vdomains&gt; recipient &lt;recipients&gt; relay via lmtp://127.0.0.1:2525

# Forward emails to local accounts to their MBOXs
accept for local alias &lt;aliases&gt; deliver to mbox

# Relay signed emails
accept tagged DKIM for any relay

# If an email was sent locally or through an authenticated user, sign
accept for any relay via smtp://127.0.0.1:10027
```

For passwd, I had to write it this way because openSMTPD at the time of writing shuts down if it finds an empty line in the passwd file, if I just looped through the accounts hash the file would have an extra blank line at the end
**Update:** Gilles is looking into this

mailsrv/conf/opensmtpd/passwd:
```none
{% raw %}{% set passwordSalt = salt['pillar.get']('salt') %}
{%- set accounts = salt['pillar.get']('accounts') %}
{%- for account in accounts[:-1] -%}
{{ account[0] }}:{{ salt['password.hash'](account[1], passwordSalt) }}:1001:1001::/vmail:/bin/nologin
{% endfor -%}
{{ accounts[-1][0] -}}
	:{{
	salt['password.hash'](
		accounts[-1][1], passwordSalt)
	-}}
:1001:1001::/vmail:/bin/nologin{% endraw %}
```

mailsrv/conf/opensmtpd/recipients:
```none
{% raw %}{% for account in salt['pillar.get']('accounts') -%}
{{ account[0] }}
{% endfor -%}{% endraw %}
```

mailsrv/conf/opensmtpd/vdomains:
```none
{% raw %}{% for domain in salt['pillar.get']('domains') -%}
{{ domain }}
{% endfor -%}{% endraw %}
```

DKIMProxy:

mailsrv/dkimproxy.sls:
```yaml
dkimproxy_out:
  service:
    - running
    - enable: True
    - watch:
      - file: /usr/local/etc/dkimproxy/keyfiles
      - file: /usr/local/etc/dkimproxy_out.conf

/usr/local/etc/dkimproxy:
  file.directory:
    - makedirs: True

/usr/local/etc/dkimproxy/keyfiles:
  file.managed:
    - source: salt://mailsrv/conf/dkimproxy/keyfiles
    - template: jinja
    - require:
      - file: /usr/local/etc/dkimproxy

/usr/local/etc/dkimproxy_out.conf:
  file.managed:
    - source: salt://mailsrv/conf/dkimproxy_out.conf
    - user: dkimproxy
    - group: dkimproxy
    - file_mode: 640
    - require:
      - file: /usr/local/etc/dkimproxy
```

mailsrv/genkeys.sls:
```none
{% raw %}{% for domain in salt['pillar.get']('domains') %}

{% set keys = salt['dkim.generate']() %}

{# Only generate keys for domains with missing files #}
{% if 1 == salt['cmd.retcode']('test -f /usr/local/etc/dkimproxy/' ~ domain ~ '/private') %}

/usr/local/etc/dkimproxy/{{ domain }}:
  file.directory:
    - makedirs: True

/usr/local/etc/dkimproxy/{{ domain }}/private:
  file.managed:
    - source: salt://mailsrv/conf/dkimproxy/domain/private
    - template: jinja
    - require:
      - file: /usr/local/etc/dkimproxy/{{ domain }}
    - context:
      keys: {{ keys }}
    - watch_in:
      - service: dkimproxy_out

/usr/local/etc/dkimproxy/{{ domain }}/public:
  file.managed:
    - source: salt://mailsrv/conf/dkimproxy/domain/public
    - template: jinja
    - require:
      - file: /usr/local/etc/dkimproxy/{{ domain }}
    - context:
      keys: {{ keys }}
      domain: {{ domain }}
    - require:
      - file: /usr/local/etc/dkimproxy/{{ domain }}/private

{% endif %}
{% endfor %}{% endraw %}
```

mailsrv/conf/dkimproxy_out.conf:
```none
# specify what address/port DKIMproxy should listen on
listen    127.0.0.1:10027

# specify what address/port DKIMproxy forwards mail to
relay     127.0.0.1:10028

sender_map /usr/local/etc/dkimproxy/keyfiles

# control how many processes DKIMproxy uses
#  - more information on these options (and others) can be found by
#    running `perldoc Net::Server::PreFork'.
min_servers   10
max_servers   40

min_spare_servers 5
```

mailsrv/conf/dkimproxy/keyfiles:
```none
{% raw %}{% set domains = salt['pillar.get']('domains') %}
{%- for domain in domains[:-1] -%}
{{ domain }} dkim(c=relaxed/simple, a=rsa-sha256,s=mailsrv,key=/usr/local/etc/dkimproxy/{{ domain }}/private)
{% endfor -%}{{ domains[-1] }} dkim(c=relaxed/simple, a=rsa-sha256,s=mailsrv,key=/usr/local/etc/dkimproxy/{{ domains[-1] }}/private){% endraw %}
```

mailsrv/conf/dkimproxy/domain/public:
```none
{% raw %}mailsrv._domainkey	IN	TXT	( "v=DKIM1; k=rsa; t=s; "
	  "p= {{ keys[1] }}" )  ; ----- DKIM key mailsrv for {{ domain }}{% endraw %}
```

Just make sure to place a valid certificate and key in states/mailsrv/conf/opensmtpd/cert and you should be good to go after running

```bash
salt-call state.highstate
# or
salt 'mailsrv' state.highstate
```

Just a note, when the first client authenticates with OpenSMTPD after a restart, the log file will show the following error
```none
Authentication temporarily failed for user user@domain```

That's OK, it will switch to the virtual user file afterwards. Not sure if this is a bug or a feature