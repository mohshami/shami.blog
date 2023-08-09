---
date: 2021-07-17T15:39:18-04:00
title: "Letsencrypt Pre-renew Hooks"
---

[Acmetool](https://github.com/hlandau/acmetool) used to be my go-to tool for LetsEncrypt. It was quick and simple to set up. As a user, my favorite part of the [Golang](https://golang.org/) ecosystem is that binary files are statically linked. You don't have to fiddle with any dependencies. But even though Acmetool is still getting occasional updates the last release is from 2018 and I prefer to stick to releases. There were times when Acmetool would not work behind Cloudflare and I would have to temporarily disable Cloudflare proxying to be able to generate certificates.<!--more-->

Another alternative was [lego](https://github.com/go-acme/lego) which is a library and command line client for the ACME protocol. I read that it was a very solid tool but what kept me from using it was that it can only manage one certificate at a time. In 2019 I managed servers with tens of websites and Acmetool didn't work so I needed a few crontab entries to manage them with lego.

I wrote a couple of wrapper scripts for lego and that made it my favorite ACME client. And while trying to figure out the setup I mentioned in [my previous article]({{<relref "letsencrypt-certificates-for-pfsense/index.md">}}) I read some posts asking for pre-renewal hooks and I realized my scripts enable that, so will be sharing them below:

The new certificate generation script:
```bash
#!/bin/sh

# Do not tolerate errors
set -e

. /root/.lego

if [ -z $PORT ]; then
    request="webroot /usr/local/www"
else
    request="port $PORT"
fi

requestCert() {
    $LEGO \
        --accept-tos \
        --path $LEGODIR \
        --http \
        --http.$request \
        --email $EMAIL \
        --domains $1 \
        --pem \
        run
}

LEGO=/usr/local/bin/lego
LEGODIR=/var/db/lego

domainsParam="$1"
shift

for domain in $*
do
    domainsParam="$domainsParam --domains $domain"
done

requestCert "$domainsParam"
```

The contents of /root/.lego
```plaintext
EMAIL=foo@bar.com       # Mandatory
PORT=127.0.0.1:402      # Optional, if not specified the acme challenge is stored in /usr/local/www/.well-known/acme-challenge, if specified, lego will listen on the defined IP and port
```

You will have to configure your web server or load balancer to use either the folder or the proxy to the port. I will not go into detail here as this is thoroughly documented online.

Usage: `acmenew domain1 [domain2 domain3 ...]`

This will generate the following set of files in /var/db/lego/certificates/
```plaintext
domain1.crt
domain1.issuer.crt
domain1.json
domain1.key
domain1.pem
```

Now for the renewal script:
```bash
#!/bin/sh

# Do not tolerate errors
set -e

. /root/.lego

if [ -z $PORT ]; then
    request="webroot /usr/local/www"
else
    request="port $PORT"
fi

renewCert() {
    # If we have a hook script in /root/.hooks, add the --renew-hook argument
    hook=""
    if [ -f /root/.hooks/$1 ]; then
        hook="--renew-hook /root/.hooks/$1"
    fi
    $LEGO \
        --accept-tos \
        --path $LEGODIR \
        --http \
        --http.$request \
        --email $EMAIL \
        --domains $1 \
        --pem \
        renew --days $DAYS ${hook}
}

# Do not attempt renewal if the certificate has more than X days available
# 86400 seconds is 1 day
DAYS=22
EXPIRSIN=`expr $DAYS \* 86400`

LEGO=/usr/local/bin/lego
LEGODIR=/var/db/lego
OPENSSL=/usr/bin/openssl

FIND=/usr/bin/find
SED=/usr/bin/sed
BASENAME=/usr/bin/basename

# Loop through current certificates
CERTS=`$FIND $LEGODIR -name '*crt' -not -name '*issuer*' -type f`

for cert in $CERTS
do
    # If the certificate expires in the period mentioned above, renew it
    $OPENSSL x509 -checkend $EXPIRSIN -noout -in $cert -out /dev/null ||
        renewCert `$BASENAME $cert | $SED 's/.crt//'`
done
```

This script does the following:
1. Loop through all certificates in /var/db/lego/certificates
1. Use openssl to check the certificate expiry date
1. Run `renewCert` only when a certificate is about to expire
1. Look for /root/.hooks/domainname, if that exists, instruct lego to run it after renewing the certificate

To add a pre-hook, all you need is to modify the beginning of `renewCert`
