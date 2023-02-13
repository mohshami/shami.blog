---
date: 2021-07-12T21:45:25-04:00
title: "HOWTO - Letsencrypt Certificates for localhost"
---

A few days ago I discovered [\*.localtest.me](http://readme.localtest.me/) which is a neat service that allows you to access localhost with multiple hostnames allowing the creation of multiple development sites without having to use `http://localhost/(site1|site2|site3)`. We all know that has some difficulties when it comes to moving those sites to production. Not all CMS's and frameworks support an easy migration.<!--more-->

One disadvantage as described on their website is SSL. You can always use a self-signed certificate, but where is the fun in that?

A good way to do it is [LetsEncrypt](https://letsencrypt.org/). If you have your own domain, you can just use the DNS provider with [ClouDNS](https://www.cloudns.net/) or [Cloudflare](https://www.cloudflare.com). If you don't already have a domain, the cheapest TLD I could find was .ovh which at the time of writing only costs 3.19$ per year.

Both Cloudflare and ClouDNS offer free plans. I happen to use Cloudflare because I utilize their other services.

I will be using my favorite ACME client, [lego](https://github.com/go-acme/lego). I don't see much written about lego even though it's very simple to use. lego supports the [following providers](https://go-acme.github.io/lego/dns/).

### Generate an API token
1. Go to "My Profile"
1. Click on "API Tokens"
1. Click on "Create Token"
1. Click on "Edit zone DNS"
1. For "Zone Resources", choose your domain. This gives the least privileges possible to this token
1. Click on "Continue to summery"
1. Click on "Create Token"
1. Store your token securely, this has access to modify your account.
1. Add an A record with the name `*.dev` and the value `127.0.0.1` to your domain

For the purpose of this HOWTO, I will be using the domain `shami.ovh` and the Windows binary for lego. Configuration for other platforms should be similar.

### Setting up lego
1. Download the binary from [here](https://github.com/go-acme/lego/releases)
1. Run the code below

```none
SET CLOUDFLARE_EMAIL=foo@bar.com
SET CF_DNS_API_TOKEN=b9841238feb177a84330febba8a83208921177bffe733
lego -a --dns cloudflare --domains *.dev.shami.ovh --email me@bar.com run
```

Now inside .lego/certificates you will find the newly generated certificate which you can use with anything.dev.shami.ovh