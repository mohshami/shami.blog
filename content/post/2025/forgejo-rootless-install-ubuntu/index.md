---
title: "Forgejo Rootless Install with Podman and Ubuntu 24.04"
date: 2025-10-25T05:23:25+03:00
---
I have recently switched from [Docker](https://www.docker.com) to [Podman](https://podman.io/), mostly because Podman's integration with SystemD feels better to me than Docker Compose, especially with [podman-quadlet](https://docs.podman.io/en/latest/markdown/podman-quadlet.1.html). Setting up rootless [Forgejo](https://forgejo.org/) with Podman took some time figuring out so I decided to document it here.<!--more-->

### Server preparation
Install a fresh copy of Ubuntu 24.04, update, and install Podman. The particular server I'm running is hosted at [Hetzner](https://www.hetzner.com). The server is configured with a Hetzner firewall that makes it only accessible over [Nebula](https://nebula.defined.net/docs/), you can use [Tailscale](https://tailscale.com/) if you want.

I like to use bind mounts backed by ZFS. This combination has served me well and has survived multiple server crashes. The easiest way to do this with Hetzner is to use a volume. I have run into a situation with Hetzner where a server would be unreachable but I could recover by creating a new server and moving the volume to the newly created server.
```bash
apt update
apt full-upgrade
apt autoremove
apt install podman zfsutils-linux

# Reboot to start fresh, not necessary but I like to do it that way
reboot

# Set up ZFS (Disk ID will be different in your case)
zpool create tank /dev/disk/by-id/scsi-SHC_Volume_103797893

# Set some good zpool and dataset properties
zpool set ashift=12 tank
zfs set atime=off tank
zfs set compression=lz4 tank
zfs set aclmode=passthrough tank
zfs set logbias=throughput tank

# Make sure Podman is working
podman run --rm helloworld
```

{{< thumbnail thumbnail="hello_world_thumb.jpg" full="hello_world.png" >}}

Create the user that all containers will run as. I'll use "git" here because that's the account users will connect with — I'll explain this further later.
```bash
useradd -m git

# This is needed for the user "git" to have persistent services running without needing someone to log in
loginctl enable-linger git
```

To run rootless Podman containers, users inside the container are mapped to actual users on the host, for this to work we have to use SUBUIDs and SUBGIDs, let's look at the ones allowed for "git".
```bash
cat /etc/subuid /etc/subgid

# Output
git:100000:65536
git:100000:65536
```

In this particular instance, "root" inside containers (UID 1) will map to UID 100000 on the host, in an Ubuntu container, "www-data" (UID 33), will be mapped to UID 100032.

Sometimes those numbers are different, an easy way to remap those SUBUIDs and SUBGIDs is as follows
```bash
# Remove all allocated SUBUIDs and SUBGIDs and assign 200001-265535
usermod --del-subuids 1-4294967295 --del-subgids 1-4294967295 --add-subuids 200001-265535 --add-subgids 200001-265535 git
```

I like to start the SUBUIDs with a "1" which makes it slightly easier to read. Root inside the container maps to UID 200001 and the www-data user maps to 200033. It has no technical difference and is just a personal preference.

### Log in as "git"
For Podman to operate correctly, you must SSH to the host as the container-running user. Forgejo, however, expects the git user for Git access rather than shell logins, so direct SSH fails; luckily there’s a fix.
```
# Install the machinectl command
apt install systemd-container

# Switch to the "git" user
machinectl shell git@.host /usr/bin/bash
```

Normally when I manage Podman containers in my homelab, I switch from root with the following command `machinectl shell --uid=podman-user`, but this will not work with Forgejo because we need to update the default shell to allow for git commands to work with Forgejo. More on that later.

### MariaDB
Forgejo needs a database, you can use SQLite or PostgreSQL. MySQL/MariaDB is what I understand, so I'm sticking with that.
```bash
# Create the required datasets (Run these commands as root, or a user that has permissions to modify the pool)
zfs create tank/mysql
zfs create tank/mysql/data
zfs create tank/mysql/log
zfs create tank/mysql/conf

# Set optimizations for MySQL
zfs set recordsize=16k tank/mysql/data
zfs set primarycache=metadata tank/mysql/data
zfs set recordsize=128k tank/mysql/log
zfs set primarycache=metadata tank/mysql/log

# Set the proper permissions
# MariaDB runs as the user "999"
chown 200999:200999 /tank/mysql/*
```

Why create "tank/mysql/..." instead of just "tank/mysql_data" and "tank/mysql_log"? Putting everything under "tank/mysql" allows us to recursively snapshot "tank/mysql" and get a consistent state in our snapshot. Also, if you end up running multiple MySQL/MariaDB instances, you can use "tank/mysql_one", "tank/mysql_other" and you get better organization.

As for the required quadlet file
```bash
# Switch to the "git" user
machinectl shell git@.host /usr/bin/bash

# The default network doesn't have DNS, for containers to communicate using names we need to create a new one
podman network create git

mkdir -p ~/.config/containers/systemd/
cd ~/.config/containers/systemd/
```

Create a file and call it "db.container", don't worry about "MARIADB_ALLOW_EMPTY_ROOT_PASSWORD=1", we'll fix that shortly.
```
[Container]
ContainerName=db
Environment=MARIADB_ALLOW_EMPTY_ROOT_PASSWORD=1
Environment=TZ=Asia/Amman
Image=docker.io/mariadb:10.6
Network=git
# We don't want MariaDB to be publically reachable
PublishPort=127.0.0.1:3306:3306
Volume=/tank/mysql/data:/var/lib/mysql
Volume=/tank/mysql/log:/var/lib/mysql_log
Volume=/tank/mysql/conf:/etc/mysql/conf.d

[Install]
WantedBy=multi-user.target default.target
```

Create the MairaDB configuration file
```
# /tank/mysql/conf/70-zfs.cnf
[mysqld]
datadir = /var/lib/mysql
innodb_flush_log_at_trx_commit = 1 # TPCC reqs.
innodb_log_file_size = 1G
innodb_log_group_home_dir = /var/lib/mysql_log
innodb_flush_neighbors = 0
innodb_fast_shutdown = 2

innodb_flush_method = fsync
innodb_doublewrite = 0 # ZFS is transactional
innodb_read_io_threads = 10
innodb_write_io_threads = 10

innodb_use_native_aio=0
innodb_log_write_ahead_size=16384

innodb_file_per_table=on
performance-schema = ON
performance_schema=ON

query_cache_type        = 1
query_cache_limit       = 256M
query_cache_size        = 1024M

skip-external-locking
skip-name-resolve

table_definition_cache=2048
join_buffer_size=16M
key_buffer_size=32M
innodb_buffer_pool_size=2G
innodb_log_file_size=512M
innodb_log_buffer_size=32M
```

Start and secure the database.
```bash
systemctl --user daemon-reload
systemctl --user start db.service
```

If you don't get an error, check the running container
```bash
podman container ls
```

{{< thumbnail thumbnail="container_ls.png" full="container_ls.png" group="container_ls" >}}

With the database now running, let's apply some security
```bash
podman exec -it db bash

# Run this inside the container
mysql_secure_installation
```

{{< thumbnail thumbnail="mysql_secure_installation_thumb.jpg" full="mysql_secure_installation.png" group="container_ls" >}}

As you've seen, we set up socket authentication without a password. This makes the database only accessible from inside the container. Next, allow management from the host.
```
MariaDB [(none)]> grant all on *.* to root@'%' identified by 'some_super_secure_password' with grant option;
```

Configure access from the host
```bash
apt install mariadb-client
```

Place the following in "/root/.my.cnf" and set the permissions to 0400
```
[client]
user=root
host=127.0.0.1
password=some_super_secure_password
```

```bash
chmod 0400 /root/.my.cnf

# Test connectivity
mysql
```

{{< thumbnail thumbnail="mysql_thumb.jpg" full="mysql.png" >}}

Create the Forgejo database

```
create database forgejo;
grant all on forgejo.* to forgejo@'%' identified by 'some_other_super_secret_password';
```

### Set up a reverse proxy with HTTPS
We'll use [Caddy](https://caddyserver.com/) running on the host to handle HTTPS. Since we're using rootless Podman the containers cannot bind to ports 80 and 443 directly. There are ways to do so, but I haven't researched the security implications.
```bash
# Download Caddy from https://caddyserver.com/download, the one that comes with Ubuntu doesn't have Cloudflare support
mv caddy /usr/local/bin/
chmod 755 /usr/local/bin/caddy
mkdir /etc/caddy
```

Create the following Caddyfile
```
repo.yourdomain.com {
        tls {
                dns cloudflare {env.CLOUDFLARE_API_TOKEN}
        }

        reverse_proxy localhost:3000
}
```

Run Caddy manually to test, check the output to make sure your certificate is being generated
```bash
cd /etc/caddy
CLOUDFLARE_API_TOKEN=MY_SUPER_SECRET_TOKEN caddy run
```

Create the SystemD unit file "/etc/systemd/system/caddy.service"
```
[Unit]
Description=Caddy
Documentation=https://caddyserver.com/docs/
After=network.target network-online.target
Requires=network-online.target

[Service]
Type=notify
User=www-data
Group=www-data
EnvironmentFile=/etc/caddy/caddy.env
ExecStart=/usr/local/bin/caddy run --environ --config /etc/caddy/Caddyfile
ExecReload=/usr/local/bin/caddy reload --config /etc/caddy/Caddyfile --force
TimeoutStopSec=5s
LimitNOFILE=1048576
LimitNPROC=512
PrivateTmp=true
ProtectSystem=full
AmbientCapabilities=CAP_NET_BIND_SERVICE

# Restart configuration
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
```

Create the required environment file "/etc/caddy/caddy.env"
```
CLOUDFLARE_API_TOKEN=MY_SUPER_SECRET_TOKEN
```

Run Caddy
```caddy
# Make sure /var/www is created and owned by www-data
mkdir /var/www
chown -R www-data:www-data /var/www

systemctl daemon-reload
systemctl enable --now caddy
```

### Forgejo
With the server ready, it's time to configure Forgejo. First we need to set up storage.
```bash
zfs create tank/forgejo

# The service runs under UID 1000 in the container
chown 201000:201000 /tank/forgejo
```

Create the following quadlet file "~/.config/containers/systemd/forgejo.container"
```
[Unit]
Description=Forgejo
# Only start Forgejo once the database is up
After=db.service
Wants=db.service

[Container]
ContainerName=forgejo
Image=codeberg.org/forgejo/forgejo:13-rootless
PublishPort=127.0.0.1:3000:3000
Network=git
Volume=/tank/forgejo:/var/lib/gitea
Volume=/etc/timezone:/etc/timezone:ro
Volume=/etc/localtime:/etc/localtime:ro

[Install]
WantedBy=multi-user.target default.target
```

Here you will see an example of how Podman is better than Docker, with Docker compose, service dependencies is only honored when running `docker compose up`, but unlike Podman/SystemD, startup order is not guaranteed when you reboot the host. If you use Nginx and need to reference another container by name, this is much simpler.

Start and secure the database.
```bash
systemctl --user daemon-reload
systemctl --user start forgejo.service
```

Now access your instance using https://repo.yourdomain.com

{{< thumbnail thumbnail="forgejo_setup_thumb.jpg" full="forgejo_setup.png" >}}

Configure Forgejo to your liking, keep "SSH server port" set to 2222, and click "Install Forgejo".

### Setting up SSH access for git
Right now our repo is accessible over HTTPS, but for SSH, the URL isn't pretty (and doesn't work, for now)

{{< thumbnail thumbnail="repo_thumb.jpg" full="repo.png" >}}

We need to setup SSH passthrough for the user "git", edit "/etc/ssh/sshd_config" and add the below to the end of the file:
```
Match User git
  AuthorizedKeysCommandUser git
  AuthorizedKeysCommand /usr/bin/podman exec -i forgejo /usr/local/bin/gitea keys -e git -u %u -t %t -k %k
```

Reload sshd
```bash
systemctl reload ssh
```

This allows Forgejo to handle SSH key authentication, when a user logs in, sshd asks Forgejo for the list of allowed public keys and if the user's matches one of them, they are let in.

Edit git's shell; create "/usr/local/bin/git-shell"
```
#!/usr/bin/env bash

/usr/bin/podman exec -i --env SSH_ORIGINAL_COMMAND="$SSH_ORIGINAL_COMMAND" forgejo sh "$@"
```

Make it executable and set it as the shell for "git"
```bash
chmod 755 /usr/local/bin/git-shell
chsh -s /usr/local/bin/git-shell git
```

Update Forgejo to know it's running under Podman instead of Docker, edit "/tank/forgejo/custom/conf/app.ini" and update the following keys
```
[server]
; Change this from 2222 to 22
SSH_PORT = 22

; Add this
SSH_AUTHORIZED_KEYS_COMMAND_TEMPLATE = {{.AppPath}} --config={{.CustomConf}} serv key-{{.Key.ID}}
```

Restart Forgejo
```bash
machinectl shell git@.host /usr/bin/bash

systemctl --user restart forgejo
```

And now you can use Git operations with SSH normally.
