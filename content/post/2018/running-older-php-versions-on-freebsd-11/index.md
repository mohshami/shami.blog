---
date: 2018-02-19T08:51:21+02:00
title: "Running Older PHP Versions on FreeBSD 11"
---

Why? You might ask yourself. Isn't it just better to upgrade the web application and save yourself the trouble of all the security issues? True, but sometimes it's just not possible or feasible. The other day I helped a friend of mine migreate from a VPS he got in 2008 to a brand new FreeBSD 11 droplet on [DigitalOcean](https://www.digitalocean.com). His customer has still not updated their site, and they were paying the same rate they've been paying since 2008. So it was better and cheaper to move them to a new VPS even though we kept the same code. At least the OS and all other components in the stack were updated.<!--more-->

First thing's first. I maintain my own repo using [Poudriere](https://github.com/freebsd/poudriere). So all installed packages come from that. We'll install everything from there except for PHP. I will be installing both PHP 4.4 and PHP 5.2 (That's what we used for the droplet).

We'll be using FreeBSD 11.1. Also, we'll be using jails to keep any security issues with PHP from affecting the whole server. We'll use NAT to provide internet access to the jails.

Add a private network to the server, this will be used for communication between the jails and the host
```plaintext
# /etc/rc.conf
cloned_interfaces="lo1"
ipv4_addrs_lo1="192.168.0.1/24"
gateway_enable="YES"
pf_enable="YES"
iocage_enable="YES"
```

Configure pf to NAT
```plaintext
# /etc/pf.conf
ext_if="MAIN_INTERFACE"
jail_if="lo1"

IP_PUB="YOUR_PUBLIC_IP_ADDRESS"

scrub in all

# nat all jail traffic
nat pass on $ext_if from 192.168.0.0/24 to any -> $IP_PUB

# No firewall, just pass everything
pass out
pass in
```

Reboot your server. Once it's back up, install and configure nginx, MySQL, ... etc. Save your web application to /usr/local/www/ as if PHP was running on host. We'll be using nullfs to mount the folder to the jails

Install IOCage to manage the jails
```bash
pkg install py36-iocage

iocage activate zroot

# Fetch the FreeBSD images
iocage fetch (Choose 11.1-RELEASE) 	# For PHP 5.2/5.3
iocage fetch (Choose 10.4-RELEASE)	# For PHP 4.4

# Create jails for running PHP 5.2 and PHP 4.4 (I couldn't get PHP 4.4 to compile on 11.x, so we're using 10.4)
iocage create --name php44 -r 10.4-RELEASE
iocage create --name php52 -r 11.1-RELEASE

# Set the IP addresses of the jails
iocage set ip4_addr="lo1|192.168.0.2" php52
iocage set ip4_addr="lo1|192.168.0.3" php44

# Set the jails to start on boot
iocage set boot=on php52
iocage set boot=on php44

# Start the jails
service iocage start

# Check jail status
iocage list

+-----+-------+-------+--------------+-------------+
| JID | NAME  | STATE |   RELEASE    |     IP4     |
+=====+=======+=======+==============+=============+
| 1   | php52 | up    | 11.1-RELEASE | 192.168.0.2 |
+-----+-------+-------+--------------+-------------+
| 2   | php44 | up    | 10.4-RELEASE | 192.168.0.3 |
+-----+-------+-------+--------------+-------------+

mkdir -p /iocage/jails/php52/root/usr/local/www/example.com
mkdir -p /iocage/jails/php44/root/usr/local/www/example.com
```

Set up the jails to mount the webroot

```plaintext
# /iocage/jails/php52/fstab
/usr/local/www/example.com /iocage/jails/php52/root/usr/local/www/example.com nullfs rw 0 0

# /iocage/jails/php44/fstab
/usr/local/www/example.com /iocage/jails/php44/root/usr/local/www/example.com nullfs rw 0 0
```

Nginx backend configuration
```plaintext
upstream php52 {
	least_conn;
	server 192.168.0.2:9000 max_fails=0;
	server 192.168.0.2:9001 max_fails=0;
	server 192.168.0.2:9002 max_fails=0;
	server 192.168.0.2:9003 max_fails=0;
	server 192.168.0.2:9004 max_fails=0;
}

upstream php44 {
	least_conn;
	server 192.168.0.3:9000 max_fails=0;
	server 192.168.0.3:9001 max_fails=0;
	server 192.168.0.3:9002 max_fails=0;
	server 192.168.0.3:9003 max_fails=0;
	server 192.168.0.3:9004 max_fails=0;
}
```

Now that we have our jails ready, lets set up PHP

PHP 5.2:
```bash
# Switch to the PHP 5.2 jail, This is the exact same process as PHP 5.3, except for one step
jexec 1

# Set up your pkgng repo

# Install build dependencies
pkg update
pkg install -y gcc-6 patch libxml2 curl jpeg png freetype2 mcrypt mariadb100-client libxslt

# Download PHP
fetch http://museum.php.net/php5/php-5.2.17.tar.gz
tar zxvf php-5.2.17.tar.gz
cd php-5.2.17

# This patch is needed for PHP 5.2 to compile on FreeBSD 11.x, not needed for PHP 5.3
feth https://shami.blog/2018/02/running-older-php-versions-on-freebsd-11/libxml29_compat.patch
gpatch -p0 < libxml29_compat.patch

# Build PHP
./configure --with-layout=GNU \
	--with-regex=php \
	--with-zend-vm=CALL \
	--enable-zend-multibyte \
	--build=FreeBSD-amd64 \
	--prefix=/usr/local/php52 \
	--exec-prefix=/usr/local/php52 \
	--with-config-file-scan-dir=/usr/local/php52/etc/php \
	--enable-mod-charset \
	--enable-fastcgi \
	--enable-libgcc \
	--with-libxml-dir=/usr/local/include/libxml2/libxml/ \
	--enable-ftp \
	--with-mysql=/usr/local/include/mysql/ \
	--with-xsl=/usr/local/include/libxslt/ \
	--with-pdo-mysql \
	--enable-mbstring \
	--with-curl \
	--disable-short-tags \
	--disable-ipv6 \
	--enable-bcmath \
	--with-curl=/usr/local/include/curl/ \
	--with-bz2 \
	--enable-exif \
	--enable-ftp \
	--with-gd \
	--with-png-dir \
	--with-jpeg-dir \
	--with-zlib-dir \
	--with-freetype-dir \
	--with-gettext \
	--enable-mbstring \
	--with-mcrypt \
	--with-mhash \
	--with-mysqli \
	--with-xmlrpc \
	--enable-soap \
	--enable-sockets \
	--enable-zip \
	--enable-calendar \
	--with-gmp \
	--with-openssl \
	--enable-pcntl \
	--with-readline \
	--enable-shmop \
	--enable-wddx

make
make install
cp php.ini-recommended /usr/local/etc/php.ini
```

PHP 4.4:
```bash
# Switch to the PHP 4.4 jail
jexec 2

# Set up your pkgng repopkg update
pkg update
pkg install mariadb100-client

# Download PHP
fetch http://museum.php.net/php4/php-4.4.9.tar.gz
tar zxvf php-4.4.9.tar.gz
cd php-4.4.9

# Build PHP
./configure --enable-fastcgi
make
cp php.ini-recommended /usr/local/etc/php.ini
```

PHP will now be installed to /usr/local/php52. Now we'll use [Supervisord](http://supervisord.org/) to keep PHP CGI running since 5.2 didn't have FPM

PHP 5.2:
```bash
pkg install py27-supervisor

$CAT >> /usr/local/etc/supervisord.conf <<EOF
[program:php52]
process_name=%(program_name)s_%(process_num)02d
command=/usr/local/php52/bin/php-cgi -b 192.168.0.2:90%(process_num)02d -c /usr/local/etc/php.ini
autostart=true
autorestart=true
user=USER
numprocs=5
redirect_stderr=true
EOF

echo supervisord_enable=YES > /etc/rc.conf.d/supervisord
service supervisord start
```

PHP 4.4:
```bash
pkg install py27-supervisor

$CAT >> /usr/local/etc/supervisord.conf <<EOF
[program:php44]
process_name=%(program_name)s_%(process_num)02d
command=/root/php-4.4.9/sapi/cgi/php -b 192.168.0.3:90%(process_num)02d -c /usr/local/etc/php.ini
autostart=true
autorestart=true
user=USER
numprocs=5
redirect_stderr=true
EOF

echo supervisord_enable=YES > /etc/rc.conf.d/supervisord
service supervisord start
```

Now that you have PHP running, you can set up nginx to use one of the upstreams defined above.