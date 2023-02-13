---
title: 'Empathy, The New Kid On The Block'
date: 2009-02-05 09:26:35
---

If you've used Linux as a desktop, you'll know it's only playing catch-up when it comes to instant messaging. I've been using Pidgin since was called Gaim, I think I started using it back in 2003. I love how minimalistic it is. Sadly the developers are going nowhere with it, at least that's my (as well as a few others) humble opinion.<!--more-->

I stumbled upon [this post](http://ubuntuforums.org/showthread.php?t=876847) which mentions a new (or maybe just new to me) client called [Empathy](http://live.gnome.org/Empathy). After playing with it for a few days now I think it has great potential. It's still pretty basic but also under heavy development. It's very minimalistic and uses the Telepathy library, which IMHO is a better approach than Pidgin's libpurple.

It still doesn't have proxy support, but you can work around that, at least for MSN and Gtalk, the protocols that I use. Here is how I did it it:

Gtalk: Just create a tunnel with SSH

```bash
ssh -C -q -f -M 0 -N -L 5223:209.85.137.125:5223
```

Where 209.85.137.125 is the IP address of talk.google.com, then set the account to use localhost as a server

MSN is a little different, this trick didn't work because the client connects to a login server, which redirects the client to a different server. MSN is implemented using the telepathy-butterfly executable. Just use a socks server like this:

```bash
mv /usr/lib/telepathy/telepathy-butterfly /usr/lib/telepathy/telepathy-butterfly-old
vi /usr/lib/telepathy/telepathy-butterfly

#!/bin/bash
exec /usr/bin/tsocks /usr/lib/telepathy/telepathy-butterfly-old

chmod +x /usr/lib/telepathy/telepathy-butterfly
```

Enjoy :)