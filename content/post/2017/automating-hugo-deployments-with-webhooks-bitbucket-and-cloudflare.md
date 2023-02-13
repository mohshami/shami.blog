---
date: 2017-09-14T17:22:23+03:00
title: "Automating Hugo Deployments With Webhooks, Bitbucket, and CloudFlare"
categories:
  - Technical
---

I've been using [Hugo](http://gohugo.io/) for a while now and love it. I don't update my blog much and with Hugo I don't need to spend more time updating the CMS than actually blogging. The markdown files are hosted at [BitBucket](https://bitbucket.org/) along with my other code and I use [CloudFlare](https://www.cloudflare.com/) for protection as well as a CDN.<!--more-->

The process for adding new content was as follows:

- Make change
- Push to BitBucket
- Log in to server
- Pull changes
- Generate the blog files
- Compress static content to prevent nginx from having to compress files for each request
- Clear CloudFlare cache

This is a relatively easy process, but I found it troublesome to have to log in to the server to publish my updates, and then clear the CloudFlare cache. I wanted to build my own webhook but always feared it might be insecure since I don't know much web development.

Recntly my friends at [Tarent](https://www.tarent.de/en/home) introduced me to [Go](https://golang.org/). It's a very interesting language and I'm currently dabbling with it to see if it's possible to use in production. While looking at the language I found [Awesome Go](https://github.com/avelino/awesome-go). One of the projects I checked was [Webhook](https://github.com/adnanh/webhook). Looked simple enough and decided to give it a go.

First, the trigger, taken from [the example page](https://github.com/adnanh/webhook/wiki/Hook-Examples)

```none
[
  {
    "id": "AWESOME_HOOK",
    "execute-command": "/usr/local/bin/deploy.sh",
    "command-working-directory": "/root",
    "trigger-rule":
    {
      "match":
      {
        "type": "ip-whitelist",
        "ip-range": "127.0.0.1"
      }
    }
  }
]
```

You will notice that I set `ip-range` to localhost instead of the list provided by the example, this is because i will set up the restriction in nginx.

Now lets look at deploy.sh:

```bash
#!/bin/sh

# This is not portable, but it works even if the env was not set
GIT=/usr/local/bin/git
TEMPPATH=/usr/local/www/shami.blog.hugo
WEBROOT=/usr/local/www/shami.blog
CURL=/usr/local/bin/curl
CHOWN=/usr/sbin/chown
FIND=/usr/bin/find
GZIP=/usr/bin/gzip
HUGO=/usr/local/bin/hugo

if [ -d $TEMPPATH ]
then
	# If the Hugo source folder exists, just pull
	cd $TEMPPATH
	$GIT pull
else
	# If the Hugo source folder doesn't exists, clone
	$GIT clone git@bitbucket.org:USER/REPO $TEMPPATH
fi

cd $TEMPPATH
# Generate the blog files
$HUGO --quiet

# Pre-compress all files to make nginx work less
$FIND $WEBROOT -type f \( -name '*.html' -o -name '*.js' -o -name '*.css' -o -name '*.xml' -o -name '*.svg' \) -exec $GZIP -k -f --best {} \;

# Set up permissions
$CHOWN -R www:www $WEBROOT

# Clear the CloudFlare cache
$CURL -X DELETE "https://api.cloudflare.com/client/v4/zones/CLOUDFLARE_ZONE_ID/purge_cache" \
     -H "X-Auth-Email: CLOUDFLARE_EMAIL_ADDRESS" \
     -H "X-Auth-Key: CLOUDFLARE_AUTH_KEY" \
     -H "Content-Type: application/json" \
     --data '{"purge_everything":true}'
```

Site configuration (Only the part to proxy the requests to Webhook):

```none
	#
	location /hooks/AWESOME_HOOK {
		# Cloudflare servers
		set_real_ip_from 103.21.244.0/22;
		set_real_ip_from 103.22.200.0/22;
		set_real_ip_from 103.31.4.0/22;
		set_real_ip_from 104.16.0.0/12;
		set_real_ip_from 108.162.192.0/18;
		set_real_ip_from 131.0.72.0/22;
		set_real_ip_from 141.101.64.0/18;
		set_real_ip_from 162.158.0.0/15;
		set_real_ip_from 172.64.0.0/13;
		set_real_ip_from 173.245.48.0/20;
		set_real_ip_from 188.114.96.0/20;
		set_real_ip_from 190.93.240.0/20;
		set_real_ip_from 197.234.240.0/22;
		set_real_ip_from 198.41.128.0/17;
		real_ip_header    X-Forwarded-For;

		# Only allow requests to the webhook from BitBucket
		allow 104.192.143.0/24;
		deny all;

		# Forward the request to webhook
		proxy_set_header X-Forwarded-Host $host;
		proxy_set_header X-Forwarded-Server $host;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		proxy_set_header Host $host;
		proxy_pass http://127.0.0.1:9000;
		client_max_body_size 1M;
	}
```

`set_real_ip_from` and `real_ip_header` tell nginx that CloudFlare will set the X-Forwarded-For header to the IP address of the client, this allows us to use the `allow` and `deny` directives as if clients were connecting directly.

All you need now is to run webhook inside `tmux` or something similar, then configure your webhook settings in BitBucket.

```bash
/usr/local/bin/webhook -verbose -hooks /usr/local/etc/webhook.json
```
