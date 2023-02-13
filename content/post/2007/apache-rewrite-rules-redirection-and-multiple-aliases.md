---
title: 'Apache, Rewrite Rules, Redirection, And Multiple Aliases'
date: 2007-03-14 11:43:14
categories:
  - Technical
---

One of our clients has a website that you can go to using multiple URLs. The server was set up in a way which does a redirection to point into a sub folder. This redirection changed the URL used to a specific one, and the client didn't like that.<!--more-->

In apache httpd, here is the fix to this to your virtual host:

```none
RewriteCond %{REQUEST_URI} ^/$ [NC]
RewriteRule "^/$" "Path/To/Folder" [R]
```

The first line is a condition that only runs the second line if the request was to the root of the web site, the [NC] makes the condition case insensitiv (Not that it actually matters here :D)

The second line redirects the request to http://domain.tld to http://domain.tld/Path/To/Folder and the [R] is to tell the browser to redirect the URL in the address bar to that address.  

Hope this is of benifit to someone.

Shami