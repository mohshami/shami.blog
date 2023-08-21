---
title: FreeBSD SCP Chroot
date: 2016-06-29 08:09:39
categories:
  - FreeBSD
---
Quick one here, if you want to create an SCP only user on FreeBSD just do the following<!--more-->

```bash
pw user add USERNAME -d /USERNAME
mkdir /path/to/chroot/folder
chown root:wheel /path/to/chroot/folder
mkdir /path/to/chroot/folder/USERNAME
chown USERNAME:USERNAME /path/to/chroot/folder/USERNAME
```

Now add the following at the end of your sshd_config
```plaintext
Match User USERNAME
    ChrootDirectory /path/to/chroot/folder
    X11Forwarding no
    AllowTcpForwarding no
    ForceCommand       internal-sftp
```

Now run `service sshd reload` And you'll be good to go. When the user logs in they will notice the path as /USERNAME. If you don't want that you can set the home direct
ory of the user to / but in that case the user would only have read only access to their home folder which might not be what you want.