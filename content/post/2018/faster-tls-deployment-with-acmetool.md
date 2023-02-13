---
date: 2018-02-19T01:04:23+02:00
title: "Faster TLS Deployment With Acmetool"
---

So lately I've been using [Ansible](https://www.ansible.com/) to manage and bootstrap my servers. I prefer the configuration management part in [Salt](https://saltstack.com) but orchestration has been much cleaner with Ansible for me. I might take another look at Salt later on but for the time being I run everything on Ansible.<!--more-->

I have a set of Ansible playbooks that handle the nginx configuration files for me. My old workflow was:

* Buy a certificate from [SSLs.com](https://ssls.com)
* Use the [DigiCert OpenSSL CSR Tool](https://www.digicert.com/easy-csr/openssl.htm) to generate a CSR
* Deploy the certificate and the private keys
* Run the Ansible playbook to generate the nginx configuration files

But now that we have [Let's Encrypt](https://letsencrypt.org/), why pay for domain validated certificated any more? So the workflow became:

* Edit the Ansible configuration to disable TLS
* Run the Ansible playbook to install nginx
* Use [acme-client](https://kristaps.bsd.lv/acme-client/) to generate the required certificates
* Restore Ansible configuration
* Re-run the Ansible playbook to update the configuration

I've been fine with that for a few months now but recently have grown tired of it. Today I discovered [acmetool](https://github.com/hlandau/acme), a nice little utility written in [Go](https://golang.org/). The features which make me like this tool more are:

* It has a built in web server, so I can generate certificates without even installing nginx
* It maintains a state folder, the configuration knows which certificates to renew without me having to specify them on the command line
* It allows me to add sub domains whereas acme-client required that I delete the old certificates and recreate from scratch. For one of my servers, I have a certificate with more than 40 SANs and those have to be declared in one shot, with acmetool I just need to run the command with each domain name and then everything works without a hassle.

So lets see how:

```bash
# Download the tool from github
fetch https://github.com/hlandau/acme/releases/download/v0.0.67/acmetool-v0.0.67-freebsd_amd64.tar.gz

# Extract the files
tar zxvf acmetool-v0.0.67-freebsd_amd64.tar.gz
cd acmetool-v0.0.67-freebsd_amd64/bin

# Run the quickstart command, this will generate the configuration folder and prepare your other certificatesS
./acmetool quickstart
```

Make sure to choose live certificates, and WEBROOT for the challenge conveyance method. Basically that tells the acmetool to use an existing web server for the challenge. But that's not we're going to do now.

Once you're done with the wizard, acmetool will create files in `/var/lib/acme`. We'll edit `/var/lib/acme/conf/target`

```yaml
request:
  provider: https://acme-v01.api.letsencrypt.org/directory
  key:
    type: rsa
  challenge:
    webroot-paths:
    - /usr/local/www/.well-known/acme-challenge
```

Just comment out the last three lines to make acmetool offer an HTTP server.

Once that done, issue the command below to generate your new certificates

```bash
./acmetool want domain1 domain2
```

That will generate the required certificates. Now edit `/var/lib/acme/conf/target` again and uncomment the last 3 lines.

Once that's done, you can run your Ansible playbook to generate the nginx configuration and since you already have a certificate ready, there is no need to change any configuration. All you need to do is point to the certificates as below:

```none
# nginx
ssl_certificate     /var/lib/acme/live/example.com/fullchain;
ssl_certificate_key /var/lib/acme/live/example.com/privkey;

# Dovecot
ssl = yes
ssl_cert = </var/lib/acme/live/example.com/fullchain
ssl_key = </var/lib/acme/live/example.com/privkey

```