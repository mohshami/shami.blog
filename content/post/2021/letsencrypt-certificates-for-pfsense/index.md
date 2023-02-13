---
date: 2021-07-17T13:38:58-04:00
title: "HOWTO - Letsencrypt Certificates for pfSense"
---

I recently helped a friend set up pfSense as a VPN server/firewall for his colocated rack. We wanted SSH and the web configurator to be accessible from a set of static IPs.<!--more-->

When we tried to enable LetsEncrypt, we found out they do not publish the list the IP addresses used for the HTTP provider. It took me a while to figure out how to securely work around that and I will be sharing it here.

In Firewall -> Aliases -> IP, start with adding an alias to all IPs you want to allow to access web configurator or SSH.
{{< thumbnail thumbnail="alias.png" full="alias.png">}}

In Firewall -> Aliases -> Ports add an alias to ports, 80, 443 and 22
{{< thumbnail thumbnail="port_alias.png" full="port_alias.png">}}

Set up the port forwarding rules. Port 8443 is what the ACME client listens on to do the TLS verification.
{{< thumbnail thumbnail="port_forward.png" full="port_forward.png">}}

From System -> Package Manager, choose "Available Packages" and install the "acme" package.

In Services -> Acme Certificates -> Account keys, Add a new key

In Services -> Acme Certificates -> Account keys, Add a new certificate with the following SAN list and Actions
{{< thumbnail thumbnail="certificate.png" full="certificate.png">}}

And you're done.

This works as follows:
* Connections from `AdminHosts` to ports 80, 443, 22 are forwarded to the same port on the LAN interface
* All other connections to port 443 are forwarded to port 8443 on the WAN interface
* Port 8443 is only active when the ACME client is running, so the port forwarding is secure

After setting things up I thought that using haproxy might have been a simpler option. But it's always better to have alternatives.