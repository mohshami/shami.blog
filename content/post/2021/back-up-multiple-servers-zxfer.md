---
date: 2021-06-21T00:55:53-04:00
title: "Back Up Multiple Servers With zxfer"
---

ZFS has been one of my favorite tools since I discovered it in 2014. I can't count how many times it has saved me from disasters. I've even had systems that wouldn't boot but still managed to recover data from them with a rescue disk.<!--more-->

When building a FreeBSD web server I create a zroot/www dataset and mount it to /usr/local/www. Then store the website files to /usr/local/www/canonical_name.tld and dump all databases to /usr/local/www/database. This enables me to snapshot the zroot/www dataset as often as I need and then transfer to a remote system. This has two advantages.

* Backups are stored on a remote system (remember, snapshots by themselves are not backups)
* Multiple versions of the files are stored locally for easy retrieval

That was easy to manage for a handful of systems, but then the number of servers I managed grew and I could no longer keep track, so I decided to write a wrapper script.

```bash
#!/bin/sh

# Default locations
ZXFER=/usr/local/sbin/zxfer

# Default configuration file
SNAPSHOTFILE="/usr/local/etc/snapshots.conf"

if [ ! -z $1 ] && [ -f $1 ] && [ ! -d $1 ]; then
    SNAPSHOTFILE=$1
fi

# Pull snapshots, and only show progress if we're running in the terminal
cat $SNAPSHOTFILE | sed 's/ *#.*//' | grep -v '^$' | while IFS=',' read -r server pool dest; do
    # Check if we are running in cron
    if [ ! -t 1 ]; then     # We don't have a terminal, then we are in cron
        $ZXFER -FkP -o copies=2,compression=zstd -R $pool -O "admin@$server" zroot/zbackup/$dest </dev/null
    else
        $ZXFER -v -D 'pv -s %%size%%' -FkP -o copies=2,compression=zstd -R $pool -O "admin@$server" zroot/zbackup/$dest </dev/null
    fi
done
```

The format for `snapshots.conf` would be

```none
192.168.0.1,zroot/www,dataset1
# Comments are allowed
192.168.0.2,zroot/www,parent_dataset/dataset2 # Comments allowed here as well
192.168.0.2,zroot/vmail,parent_dataset/dataset2
```

This will:
* Sync zroot/www from 192.168.0.1 to zroot/backup/dataset1/www on the backup server
* Sync zroot/www from 192.168.0.2 to zroot/backup/parent_dataset/dataset2/www on the backup server
* Sync zroot/vmail from 192.168.0.2 to zroot/backup/parent_dataset/dataset2/vmail on the backup server

Multiple configuration files can be created for different backup schedules.

The `if [ ! -t 1 ]; then` statement detects if the script was running in CRON or interactively, if the script ran through CRON all zxfer output is silenced but if it was run interactively then the snapshots are piped through `pv` which gives us some information like progress and speed, which is particularly useful when syncing the initial group of snapshots to the remote backup server. You would want to know that your transfer is slow for some reason sooner than later.

The script runs on the backup server which causes it to pull all snapshots from the configured servers. This allows us to:
* Secure the backup server, the backup server I used then had a hardened firewall that only allowed any kind of traffic from only 3 IP addresses. If a web server was compromised for any reason the attacker would not have access to sabotage the backups
* Grant the backup server the least amount of privileges required to do the backup, this is done with `zfs allow -ldu admin send DATASET`