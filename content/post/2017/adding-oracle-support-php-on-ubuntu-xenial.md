---
date: 2017-04-24T11:29:10+03:00
title: Adding Oracle Support PHP On Ubuntu Xenial
categories:
  - Linux
  - Technical
---

I've been recently asked to enable a web server running to PHP to connect to an Oracle database for a client. Sadly this doesn't work natively on FreeBSD so I'm documenting how I managed to do it on Ubuntu Xenial. This was inspired by [this post](https://www.syahzul.com/2016/04/06/how-to-install-oci8-on-ubuntu-14-04-and-php-5-6/) and [this post](http://www.gilfillan.space/2016/04/24/install-oracle-instant-client-1604/).<!--more-->

Update System:
--------------

```bash
apt-get update
apt-get upgrade
apt-get dist-upgrade
apt-get install zip
reboot
```

Download Instant Client drivers:
--------------------------------

Download the files below from [Oracle](http://www.oracle.com/technetwork/database/features/instant-client/index-097480.html)

```none
instantclient-basic-linuxAMD64-10.1.0.5.0-20060519.zip
instantclient-sdk-linuxAMD64-10.1.0.5.0-20060519.zip
instantclient-sqlplus-linuxAMD64-10.1.0.5.0-20060519.zip
```

Prepare installation location:
------------------------------

Create the folder as below and upload the Instant Client files to that location

```bash
mkdir /opt/oracle
```

Extract files:
--------------

```bash
cd /opt/oracle
unzip instantclient-basic-linuxAMD64-10.1.0.5.0-20060519.zip
unzip instantclient-sdk-linuxAMD64-10.1.0.5.0-20060519.zip
unzip instantclient-sqlplus-linuxAMD64-10.1.0.5.0-20060519.zip
mv instantclient10_1 instantclient
```

Update ldconfig:
----------------

Create symlinks to the so files

```bash
cd instantclient
ln -s libclntsh.so.10.1 libclntsh.so
ln -s libocci.so.10.1 libocci.so
```

Run ldconfig

```bash
echo /opt/oracle/instantclient > /etc/ld.so.conf.d/oracle-instantclient.conf
ldconfig -v
```

Prepare and test connectivity:
------------------------------

Add the following to the end of .bashrc

```bash
export PATH=$PATH:/opt/oracle/instantclient
export ORACLE_HOME="/opt/oracle/instantclient"
export OCI_LIB="/opt/oracle/instantclient"
export TNS_ADMIN="/opt/oracle/instantclient/network/admin"
```

Reload .bashrc:

```bash
source ~/.bashrc
```

Create the tnsnames.ora file

```bash
mkdir -p /opt/oracle/instantclient/network/admin
```

Contents:

```none
# /opt/oracle/instantclient/network/admin/tnsnames.ora
MYDATABASE=
 (description=
   (address_list=
     (address = (protocol = TCP)(host = IPADDRESS)(port = PORT))
   )
 (connect_data =
   (service_name=DATABASESID)
 )
)
```

Test:

```bash
sqlplus USER/PASSDWORD@MYDATABASE
```

This is what you should see if everything was successful:

```none
SQL*Plus: Release 10.1.0.5.0 - Production on Mon Apr 24 05:05:49 2017

Copyright (c) 1982, 2005, Oracle.  All rights reserved.


Connected to:
Oracle Database 11g Enterprise Edition Release 11.2.0.4.0 - 64bit Production
With the Partitioning, OLAP, Data Mining and Real Application Testing options

SQL>
```

Install the required packages to compile OCI8:
----------------------------------------------

```bash
apt-get install php-pear php-dev build-essential libaio1
```

Install OCI8 through pecl

```bash
pecl install oci8
```

Answer with the following:

```none
Client [autodetect] : instantclient,/opt/oracle/instantclient
```

Add to the available PHP modules

```bash
echo extension=oci8.so > /etc/php/7.0/mods-available/oci8.ini
```

Enable the extension (Here we will do it for CLI)

```bash
ln -s /etc/php/7.0/mods-available/oci8.ini /etc/php/7.0/cli/conf.d/
```

Check if the module was indeed enabled

```none
php -m
[PHP Modules]
calendar
Core
ctype
date
dom
exif
fileinfo
filter
ftp
gettext
hash
iconv
json
libxml
oci8
openssl
pcntl
pcre
PDO
Phar
posix
readline
Reflection
session
shmop
SimpleXML
sockets
SPL
standard
sysvmsg
sysvsem
sysvshm
tokenizer
wddx
xml
xmlreader
xmlwriter
xsl
Zend OPcache
zlib

[Zend Modules]
Zend OPcache
```

Congratulations. You are now done :)
