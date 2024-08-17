---
title: "Using SSH ProxyJump only when necessary"
date: 2024-08-15T08:47:06-04:00
---
One thing I've wanted to do for the longest time was to be able to use SSH with an alias and have ssh choose the bastion host automatically.

[This trick](https://mike.place/2017/ssh-match/) was ok at first, but I wanted something more flexible and I came up with the following:<!--more-->

```
Match host web1 exec "~/.ssh/network_detect/office"
  Hostname 10.1.0.1
  IdentityFile ~/.ssh/public_keys/ed25519.pub
  ProxyJump none

Match host web1 exec "~/.ssh/network_detect/home"
  Hostname 10.1.0.1
  IdentityFile ~/.ssh/public_keys/ed25519.pub
  ProxyJump home-bastion

Match host web1 exec "~/.ssh/network_detect/wireguard"
  Hostname 10.1.0.1
  IdentityFile ~/.ssh/public_keys/ed25519.pub
  ProxyJump wg-bastion
```

Now for the network_detect
```
# ~/.ssh/network_detect/office
#!/usr/bin/env bash

ip addr show | fgrep -q 'inet 10.1.0'

# ~/.ssh/network_detect/home
#!/usr/bin/env bash

ip addr show | fgrep -q 'inet 192.168.1'

# ~/.ssh/network_detect/wireguard
#!/usr/bin/env bash

ip link show wg_connection_name > /dev/null 2>&1
```

Which basically returns true based on the networks the client is connected to, either by searching for the network address or checking if the interface exists. This also allows using more than one bastion host.

ssh will go through all `Match` statemens in the order they appear in this file and apply previously-unapplied configurations, so the configuration above can be reduced to

```
Match host web1
  Hostname 10.1.0.1
  IdentityFile ~/.ssh/public_keys/ed25519.pub

Match host web1 exec "~/.ssh/network_detect/home"
  ProxyJump home-bastion

Match host web1 exec "~/.ssh/network_detect/wireguard"
  ProxyJump wg-bastion
```

When the user runs `ssh web1`, the following takes place:
1. `Match host web1` will be found, `Hostname 10.1.0.1` and `IdentityFile ~/.ssh/public_keys/ed25519.pub` will be applied.
1. ssh runs `~/.ssh/network_detect/home`, if that returns 0 then `ProxyJump home-bastion` will be applied.
1. ssh runs `~/.ssh/network_detect/wireguard`, if that returns 0 then `ProxyJump wg-bastion` will be applied, but only if `ProxyJump home-bastion` was not applied already.
1. If either `ProxyJump home-bastion` or `ProxyJump wg-bastion` was applied, the bastion host is used, otherwise connect to the server directly.

So if you're home and have wireguard running, ssh will always connect through home-bastion
