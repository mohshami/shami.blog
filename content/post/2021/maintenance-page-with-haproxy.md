---
date: 2021-07-26T03:00:12-04:00
title: "Maintenance Pages With HAProxy"
---

**Edit: 31/7/2021:** Add content for maintenance pages.

I currently work with a group of very smart individuals and I learn a lot from them on almost daily basis. One thing they have done which I found cool was using [Terraform](https://www.terraform.io/) to configure the [AWS Application Load Balancer](https://aws.amazon.com/elasticloadbalancing/application-load-balancer/) to display the notice during maintenance windows.<!--more-->

I wanted to see if my favorite load balancer [HAProxy](https://www.haproxy.org/) could do it and turns out it can, and you can find the required configuration below. It assumes running multiple web applications with one server each, modifying the configuration to suit your requirements should be simple to do.

`/etc/haproxy/haproxy.cfg`
```plaintext
global
    log /dev/log    local0
    log /dev/log    local1 notice
    chroot /var/lib/haproxy
    user haproxy
    group haproxy
    daemon

    # See: https://ssl-config.mozilla.org/#server=haproxy&server-version=2.0.3&config=intermediate
    ssl-default-bind-ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
    ssl-default-bind-ciphersuites TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256
    ssl-default-bind-options ssl-min-ver TLSv1.2 no-tls-tickets

    ssl-dh-param-file /etc/haproxy/dhparams.pem

defaults
    log     global
    mode    http
    option  httplog
    option  dontlognull
    timeout connect 500
    timeout client  5000
    timeout server  5000

frontend terminator
    bind PUBLIC_IP:80
    bind PUBLIC_IP:443 ssl crt-list /etc/haproxy/certs alpn h2,http/1.1

    # LetsEncrypt
    acl acme path_dir /.well-known/acme-challenge

    acl maintenance_mode hdr(host),map(/etc/haproxy/maintenance) -m found
    acl whitelist src -f /etc/haproxy/whitelist

    http-response set-header Strict-Transport-Security max-age=15768000 if { ssl_fc }
    http-request set-header X-Forwarded-Proto https if  { ssl_fc }
    # The ACME protocol doesn't like it when it gets redirected
    redirect scheme https code 301 if !{ ssl_fc } !acme

    use_backend acme if acme

    # Actual Routing
    use_backend %[req.hdr(host),lower,map(/etc/haproxy/maintenance)] if maintenance_mode !whitelist
    use_backend %[req.hdr(host),lower,map(/etc/haproxy/backends)]

backend acme
    server acmetool 127.0.0.1:402

# Actual backends
backend webapp1
    server server1 127.0.0.1:8080

backend webapp2
    server server1 127.0.0.1:8081

# Maintenance backends
backend webapp1_maintenance
    errorfile 503 /etc/haproxy/maintenance_pages/webapp1.http

backend webapp2_maintenance
    errorfile 503 /etc/haproxy/maintenance_pages/webapp2.http
```

`/etc/haproxy/whitelist`
```plaintext
# Networks listed here bypass all maintenance pages
192.168.0.0/24
```

`/etc/haproxy/maintenance`
```plaintext
# Uncomment lines below to enable the maintenance page for the desired web application
#webapp1.com  webapp1_maintenance
#webapp2.com  webapp2_maintenance
```

`/etc/haproxy/backends`
```plaintext
webapp1.com  webapp1
webapp2.com  webapp2
```

As for the maintenance pages
```plaintext
HTTP/1.0 503 Service Unavailable
Cache-Control: no-cache
Connection: close
Content-Type: text/html

<html><body><h1>Maintenance</h1>
The system is undergoing maintenance, sorry for the inconvenience
</body></html>
```