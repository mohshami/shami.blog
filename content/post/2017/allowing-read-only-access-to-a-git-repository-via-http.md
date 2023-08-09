---
date: "2017-04-02"
title: "Allowing Read-Only Access To A Git Repository Via HTTP"
categories:
  - Technical
---

Today I thought about a way to easily distribute an [Ansible](https://www.ansible.com/) playbook. I thought about having a tgz file somewhere but I wanted read only access through HTTP in case I wanted to update clients that have already downloaded the content.

The easiest solution I have found was using [cgit](https://git.zx2c4.com/cgit/about/). Simply run it with [nginx](https://www.nginx.com) and [fcgiwrap](https://github.com/gnosek/fcgiwrap).<!--more-->

```plaintext
server {
    listen                80;
    server_name           git.example.com;
    root                  /usr/local/www/cgit;
    try_files             $uri @cgit;

    location @cgit {
      include             fastcgi_params;
      fastcgi_param       SCRIPT_FILENAME $document_root/cgit.cgi;
      fastcgi_param       PATH_INFO       $uri;
      fastcgi_param       QUERY_STRING    $args;
      fastcgi_param       HTTP_HOST       $server_name;
      fastcgi_pass        unix:/var/run/fcgiwrap/fcgiwrap.sock;
    }
  }
```

```plaintext
#/etc/rc.conf
fcgiwrap_socket_owner=www
fcgiwrap_user="www"
fcgiwrap_enable="YES"
```

```plaintext
#/usr/local/etc/cgitrc
#
# cgit config
#

css=/cgit.css
logo=/cgit.png

# if you do not want that webcrawler (like google) index your site
robots=noindex, nofollow

# if cgit messes up links, use a virtual-root. For example has cgit.example.org/ this value:
virtual-root=/

# Use the following to scan for repositories in a folder
# scan-path=/usr/local/www/

repo.url=MyRepo
repo.path=/usr/local/www/git
repo.desc=This is my git repository
```
