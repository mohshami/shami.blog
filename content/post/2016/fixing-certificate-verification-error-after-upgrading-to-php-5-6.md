---
title: "Fixing Certificate Verification Error After Upgrading to PHP 5.6"
date: "2016-09-25 14:09:14"
categories:
  - FreeBSD
---

Since PHP 5.5 reached it's end of life a while back I started upgrading my servers to PHP 5.6. This has caused some issues but the worst was:

```plaintext
error:14090086:SSL routines:SSL3_GET_SERVER_CERTIFICATE:certificate verify failed
```
<!--more-->

This caused all encrypted communications to fail causing all kinds of grief. What I found strange was the fact I had already installed the ca_root_nss package which should contain the latest set of certificate authority certificates.

The solution is simple, taken from [here](https://github.com/composer/composer/issues/3346)

```bash
# Install ca_root_nss
pkg install ca_root_nss

# Update /etc/ssl/cert.pem
rm /etc/ssl/cert.pem
ln -s /usr/local/share/certs/ca-root-nss.crt /etc/ssl/cert.pem

# Restart php-fpm just in case
service php-fpm restart
```