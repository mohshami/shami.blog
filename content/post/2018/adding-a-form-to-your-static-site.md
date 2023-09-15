---
date: 2018-03-09T22:54:22+02:00
title: "Adding a Form to Your Static Site"
---

I've become a big fan of [static site generators](https://www.staticgen.com/) lately, especially [Hugo](http://gohugo.io/). It's true, static site generators are not for everybody, but most websites on the Internet can be easily implemented as static sites. Also, static sites are great for those websites that you can't regularly maintain, they are secure, fast, and very easy to set up. Take this blog for example, I don't have much time to maintain and apply security patches so having it set up as HTML is perfect for me.<!--more-->

When I try to explain static sites to people, the first thing they argue against is the lack of interactivity, like form handling. I helped my brother build a website last year and chose to go with [Grav](https://getgrav.org/) for that reason alone. Grav is great but my brother couldn't keep it updated because of the lack of Grav consultants as opposed to WordPress or Drupal. I liked Grav because it didn't use a database and for a small site as my brother's, it seemed better to go with a simpler CMS than something like the big boys.

A while back I got introduced to the wonderful world of [Go](https://golang.org/) and instantly got hooked. One of the great resources I found was [Awesome Go](https://www.awesome-go.com/). In a [pervious article]({{< ref "/post/2017/automating-hugo-deployments-with-webhooks-bitbucket-and-cloudflare.md" >}}) I mentioned how I use [Webhook](https://github.com/adnanh/webhook) to automate the deployment of this blog. This post builds on it.

For this example, we'll be using the contact form from my brother's website, it is a simple form with Google reCaptcha. With no further ado, lets begin.

webhook.json:
```json
[
  {
    "id": "contact",
    "execute-command": "/usr/local/bin/contact.sh",
    "command-working-directory": "/tmp",
    "pass-arguments-to-command":
    [
      {
        "source": "header",
        "name": "CF-Connecting-IP"
      },
      {
        "source": "payload",
        "name": "name"
      },
      {
        "source": "payload",
        "name": "email"
      },
      {
        "source": "payload",
        "name": "phone"
      },
      {
        "source": "payload",
        "name": "g-recaptcha-response"
      },
      {
        "source": "payload",
        "name": "message"
      }
    ],
    "include-command-output-in-response": true,
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

Note: I'm using `CF-Connecting-IP` above because the site runs behind CloudFlare. You can use X-Forwarded-For if requests go directly to your server.

nginx site configuration:
```plaintext
# Basic nginx configuration for a static site plus a reverse proxy
server {
        listen 80;
        expires epoch;

        server_name SERVERNAME;

        root /usr/local/www/DOMAIN;

        # Security headers, taken from https://gist.github.com/plentz/6737338
        add_header X-Frame-Options SAMEORIGIN;
        add_header X-Content-Type-Options nosniff;
        add_header X-XSS-Protection "1; mode=block";

        location / {
                index index.html;
        }

        location /hooks/contact {
        		# Only allow POSTs
                limit_except POST {
                        deny  all;
                }

                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header Host $host;
                proxy_pass http://127.0.0.1:9000;
                client_max_body_size 1M;
        }
}

```

The form:
```html
<form action="/hooks/contact" method="POST" id="form_submit">
<h3>Contact Form</h3>
<div class="form-group ">
<label for="name" class="sr-only">Name</label>
<input id="name" class="form-control" placeholder="Name" type="text" name="name" required>
</div>
<div class="form-group ">
<label for="email" class="sr-only">Email</label>
<input id="email" class="form-control" placeholder="Email" type="email" name="email" required>
</div>
<div class="form-group ">
<label for="phone" class="sr-only">Phone</label>
<input id="phone" class="form-control" placeholder="Phone" type="text" name="phone">
</div>
<div class="form-group">
<label for="message" class="sr-only">Message</label>
<textarea id="message" cols="30" rows="5" class="form-control" placeholder="Message" name="message" required></textarea>
</div>
<div class="form-group ">
<div class="g-recaptcha" data-sitekey="YOURSITEKEYHERE"></div>
<script src='https://www.google.com/recaptcha/api.js'></script>
</div>
<div class="alert alert-danger hidden" id="form_msgs">
<span></span>
</div>
<div class="form-group ">
<input class="btn btn-primary btn-lg" id="form_btn" value="Send Message" type="button">
</div>
</div>
</form>
```

Very straight forward so far, we have a form that POSTs to a location, nginx will serve the static site but will proxy POSTs to the form action to Webhook. Webhook will extract the data from the POST and provide them to our script. Webhook takes care of any missing parameters and will forward them as empty strings making our verification much easier. I chose to use a shell script for the check to make things simple, but anything works. You can go with a shell script like I did or you can go with Go or even C if you want. It's up to you.

```bash
#!/bin/sh

PUBLIC_KEY="YOUR_RECAPTCHA_PUBLIC_KEY"
PRIVATE_KEY="YOUR_RECAPTCHA_PRIVATE_KEY"
gURL="https://www.google.com/recaptcha/api/siteverify";

# Check if any parameter was null, Phone is ok
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$5" ] || [ -z "$6" ]
then
   exit 1
fi

# Evaluate recaptcha
IP="$1"
rResponse="$5"

RESULT=`/usr/local/bin/curl -d "secret=${PRIVATE_KEY}&response=${rResponse}&remoteip=${IP}" -X POST -s $gURL`

# If the captcha didn't verify, then return an error
case "$RESULT" in 
  *false*)
    echo '{"error":"Unexpected error, please try again later"}'
    exit 0
    ;;
esac

MESSAGE=`printf "Name: %s\nEmail: %s\nPhone: %s\nMessage:\n%s" "$2" "$3" "$4" "$6"`

echo "$MESSAGE" | mail -s "New contact" RECIPIENT_EMAIL

echo '{"success":"Your message has been sent successfully! We will get back to you as soon as possible"}'
```
