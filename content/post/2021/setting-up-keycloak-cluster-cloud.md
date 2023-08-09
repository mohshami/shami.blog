---
date: 2021-07-25T00:05:55-04:00
title: "HOWTO - Build a Keycloak/Ubuntu/MariaDB Cluster Without Multicast UDP"
---

I've been trying to learn more about Keycloak lately but two things kept frustrating me; a lot of the information available online doesn't work and cloud providers blocking [multicast UDP](https://en.wikipedia.org/wiki/Multicast). I lost my notes once too many and decided to document the whole process here for future reference. I used `jboss-cli.sh` to edit `standalone-ha.xml` to make it easier to automate with configuration managers. So lets begin.<!--more-->

Create two or more servers in your favorite cloud provider, make sure to set up a private network. For the purpose of this HOWTO, we have the following:
* Keycloak 14.0.0, which is the latest version as of the time of this writing
* Two servers; keycloak1 and keycloak2. Running Ubuntu 20.04. Any other OS should work with minor modifications.
* MariaDB 10.3, running on keycloak1
* haproxy, running on keycloak1
* The private IP for keycloak1 is 172.16.0.2
* The private IP for keycloak2 is 172.16.0.3

### Server preparation
Upgrade Ubuntu, then reboot
```bash
apt update
apt full-upgrade
apt autoremove
reboot
```

Add the following entries to `/etc/hosts` on both servers. This enables the servers to communicate with each other over the private LAN using names instead of IPs. This is optional but I find it makes configuration files a bit easier to comprehend.
```
172.16.0.2 keycloak1
172.16.0.3 keycloak2
```

On keycloak1, install MariaDB, make sure to edit `/etc/mysql/mariadb.conf.d/50-server.cnf` and set `bind-address` to 172.16.0.2
```bash
apt install mariadb-server
```

Create the keycloak database, set the character set and collation because Keycloak will fail to startup without
```sql
CREATE DATABASE keycloak CHARACTER SET latin1 COLLATE latin1_swedish_ci;
GRANT ALL ON keycloak.* TO keycloak@'172.16.0.%' identified by 'keycloak';
```

If you don't set the character set and collation, you will run into the following error
```plaintext
Change Set META-INF/jpa-changelog-1.9.1.xml::1.9.1::keycloak failed.  Error: Row size too large. The maximum row size for the used table type, not counting BLOBs, is 65535. This includes storage overhead, check the manual
```

Install OpenJDK 8 and download [Keycloak](https://www.keycloak.org/downloads) to /opt
```bash
apt install openjdk-8-jdk-headless

cd /opt
wget https://github.com/keycloak/keycloak/releases/download/14.0.0/keycloak-14.0.0.tar.gz
tar zxvf keycloak-14.0.0.tar.gz
```

### Keycloak preparation
Download and set up the [MySQL connector](https://dev.mysql.com/downloads/connector/j/)
```bash
mkdir -p /opt/keycloak-14.0.0/modules/system/layers/keycloak/com/mysql/main

tar zxvf mysql-connector-java-8.0.26.tar.gz
cp mysql-connector-java-8.0.26/mysql-connector-java-8.0.26.jar /opt/keycloak-14.0.0/modules/system/layers/keycloak/com/mysql/main
```

Create `/opt/keycloak-14.0.0/modules/system/layers/keycloak/com/mysql/main/module.xml`
```xml
<?xml version="1.0" ?>
<module xmlns="urn:jboss:module:1.3" name="com.mysql">
 <resources>
  <resource-root path="mysql-connector-java-8.0.26.jar" />
 </resources>
 <dependencies>
  <module name="javax.api"/>
  <module name="javax.transaction.api"/>
 </dependencies>
</module>
```

Now that the MySQL driver is ready, we need to tell Keycloak to load it. Create `driver.cli`
```bash
embed-server --server-config=standalone-ha.xml -c

# Add mysql driver if it doesn't already exist
if (outcome != success) of /subsystem=datasources/jdbc-driver=mysql:read-resource
   /subsystem=datasources/jdbc-driver=mysql:add(driver-name=mysql,\
   driver-module-name=com.mysql,\
   driver-class-name=com.mysql.cj.jdbc.Driver,\
   driver-xa-datasource-class-name=com.mysql.cj.jdbc.MysqlXADataSource)
end-if

quit
```

Load the MySQL driver.
```bash
/opt/keycloak-14.0.0/bin/jboss-cli.sh --file=driver.cli
```

Now to define the datasource. Create `datasource.cli`
```plaintext
embed-server --server-config=standalone-ha.xml -c

# Remove old database connection if it exists
if (outcome == success) of /subsystem=datasources/data-source=KeycloakDS:read-resource
   data-source remove --name=KeycloakDS
end-if

# Add new database connection if it does not exist
if (outcome != success) of /subsystem=datasources/xa-data-source=KeycloakDS:read-resource
   xa-data-source add \
      --name=KeycloakDS \
      --driver-name=mysql \
      --jndi-name=java:jboss/datasources/KeycloakDS \
      --user-name=keycloak \
      --password="keycloak" \
      --valid-connection-checker-class-name=org.jboss.jca.adapters.jdbc.extensions.mysql.MySQLValidConnectionChecker \
      --exception-sorter-class-name=org.jboss.jca.adapters.jdbc.extensions.mysql.MySQLExceptionSorter

   /subsystem=datasources/xa-data-source=KeycloakDS/xa-datasource-properties=ServerName:add(value=keycloak1)
   /subsystem=datasources/xa-data-source=KeycloakDS/xa-datasource-properties=DatabaseName:add(value=keycloak)
end-if

quit
```

Load the datasource.
```bash
/opt/keycloak-14.0.0/bin/jboss-cli.sh --file=datasource.cli
```

Create `/opt/jboss.properties`. This file will allow us to define variables in standalone-ha.xml. The values below are for keycloak1, substitute keycloak1 with keycloak2 and 172.16.0.2 with 172.16.0.3 for keycloak2.
```plaintext
jboss.server.name=keycloak
jboss.node.name=keycloak1
jboss.bind.address=172.16.0.2
jboss.bind.address.private=172.16.0.2
```

Now lets run keycloak on keycloak1 and keycloak2 independently to see if it starts. When Keycloak runs for the first time it creates the required tables in MySQL.
```bash
/opt/keycloak-14.0.0/bin/standalone.sh --server-config=standalone-ha.xml --properties=/opt/jboss.properties
```

If you see the below then you are good to proceed. Otherwise go back and see what is wrong
```plaintext
INFO  [org.jboss.as] (Controller Boot Thread) WFLYSRV0051: Admin console listening on http://127.0.0.1:9990
```

Add an admin user to be able to log in to the master realm
```bash
/opt/keycloak-14.0.0/bin/add-user-keycloak.sh -u admin
```

### Cluster configuration
Now that we have Keycloak working, it's time to configure clustering. Keycloak uses multicast UDP by default which is blocked by cloud providers. I will be explaining three options here, only one of them needs to be implemented.
* TCPPING, where you define all hosts statically in standalone-ha.xml. Can easily be automated with your configuration manager. This is my personal preference.
* DNS_PING, uses an A or SRV record to point to the private IPs of the cluster members. I haven't looked at how it would work with SRV and will explain how to use the A record. This would usually be used with Kubernetes.
* JDBC_PING, uses a database table to keep track of cluster nodes, not my favorite method but keeping it here as an option. I have run into cases where nodes would not properly clean up the table when shutting down. Bringing the cluster back up would involve shutting down all nodes, truncating the table and then starting all nodes back up.

#### TCPPING
Create `tcpping.cli`
```plaintext
embed-server --server-config=standalone-ha.xml

if (outcome == success) of /subsystem=jgroups/stack=tcpping:read-resource
    /subsystem=jgroups/channel=ee:write-attribute(name=stack,value=tcp)
    /subsystem=jgroups/stack=tcpping:remove()
end-if

/subsystem=jgroups/stack=tcpping:add
/subsystem=jgroups/stack=tcpping/transport=TCP:add(socket-binding=jgroups-tcp)
/subsystem=jgroups/stack=tcpping/protocol=TCPPING:add
/subsystem=jgroups/stack=tcpping/protocol=TCPPING/property=initial_hosts:add(value=${initial.hosts:127.0.0.1[7600]})
/subsystem=jgroups/stack=tcpping/protocol=TCPPING/property=port_range:add(value=0)
/subsystem=jgroups/stack=tcpping/protocol=MERGE3:add
/subsystem=jgroups/stack=tcpping/protocol=FD_SOCK:add(socket-binding=jgroups-tcp-fd)
/subsystem=jgroups/stack=tcpping/protocol=FD:add
/subsystem=jgroups/stack=tcpping/protocol=VERIFY_SUSPECT:add
/subsystem=jgroups/stack=tcpping/protocol=pbcast.NAKACK2:add
/subsystem=jgroups/stack=tcpping/protocol=UNICAST3:add
/subsystem=jgroups/stack=tcpping/protocol=pbcast.STABLE:add
/subsystem=jgroups/stack=tcpping/protocol=pbcast.GMS:add
/subsystem=jgroups/stack=tcpping/protocol=MFC:add
/subsystem=jgroups/stack=tcpping/protocol=FRAG2:add
/subsystem=jgroups/channel=ee:write-attribute(name=stack,value=tcpping)
quit
```

Load the TCPPING configuration.
```bash
/opt/keycloak-14.0.0/bin/jboss-cli.sh --file=tcpping.cli
```

Add the line below to `/opt/jboss.properties`
```plaintext
initial.hosts=keycloak1[7600],keycloak2[7600]
```

#### DNSPING
Create `dnsping.cli`
```plaintext
embed-server --server-config=standalone-ha.xml

if (outcome == success) of /subsystem=jgroups/stack=dnsping:read-resource
    /subsystem=jgroups/channel=ee:write-attribute(name=stack,value=tcp)
    /subsystem=jgroups/stack=dnsping:remove()
end-if

if (outcome == success) of /socket-binding-group=standard-sockets/socket-binding=jgroups-dnsping:read-resource
    /socket-binding-group=standard-sockets/socket-binding=jgroups-dnsping:remove()
end-if
/socket-binding-group=standard-sockets/socket-binding=jgroups-dnsping:add(interface="private")

/subsystem=jgroups/stack=dnsping:add
/subsystem=jgroups/stack=dnsping/transport=TCP:add(socket-binding=jgroups-tcp)
/subsystem=jgroups/stack=dnsping/protocol=dns.DNS_PING:add(socket-binding=jgroups-dnsping)
/subsystem=jgroups/stack=dnsping/protocol=dns.DNS_PING/property=dns_query:add(value=${dns.query:127.0.0.1})
/subsystem=jgroups/stack=dnsping/protocol=MERGE3:add
/subsystem=jgroups/stack=dnsping/protocol=FD_SOCK:add(socket-binding=jgroups-tcp-fd)
/subsystem=jgroups/stack=dnsping/protocol=FD:add
/subsystem=jgroups/stack=dnsping/protocol=VERIFY_SUSPECT:add
/subsystem=jgroups/stack=dnsping/protocol=pbcast.NAKACK2:add
/subsystem=jgroups/stack=dnsping/protocol=UNICAST3:add
/subsystem=jgroups/stack=dnsping/protocol=pbcast.STABLE:add
/subsystem=jgroups/stack=dnsping/protocol=pbcast.GMS:add
/subsystem=jgroups/stack=dnsping/protocol=MFC:add
/subsystem=jgroups/stack=dnsping/protocol=FRAG2:add
/subsystem=jgroups/channel=ee:write-attribute(name=stack,value=dnsping)
quit
```

Load the DNSPING configuration.
```bash
/opt/keycloak-14.0.0/bin/jboss-cli.sh --file=dnsping.cli
```

Add the line below to `/opt/jboss.properties`
```plaintext
dns.query=HOSTNAME
```

`HOSTNAME` needs to point to the private IPs of all your Keycloak servers, assuming `keycloak.example.com`
```plaintext
dig keycloak.example.com

; <<>> DiG 9.16.1-Ubuntu <<>> keycloak.example.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 41774
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65494
;; QUESTION SECTION:
;keycloak.example.com.    IN      A

;; ANSWER SECTION:
keycloak.example.com. 42  IN      A       172.16.0.2
keycloak.example.com. 42  IN      A       172.16.0.3

;; Query time: 0 msec
;; SERVER: 127.0.0.53#53(127.0.0.53)
;; WHEN: Sun Jul 25 05:13:48 CEST 2021
;; MSG SIZE  rcvd: 87
```

You can either set up a public hostname or configure a private DNS server to serve the required record. I will not go into details of the process here.

#### JDBC_PING
create `jdbcping.cli`
```plaintext
embed-server --server-config=standalone-ha.xml

if (outcome == success) of /subsystem=jgroups/stack=jdbcping:read-resource
    /subsystem=jgroups/channel=ee:write-attribute(name=stack,value=tcp)
    /subsystem=jgroups/stack=jdbcping:remove()
end-if

/subsystem=jgroups/stack=jdbcping:add
/subsystem=jgroups/stack=jdbcping/transport=TCP:add(socket-binding=jgroups-tcp)
/subsystem=jgroups/stack=jdbcping/protocol=JDBC_PING:add(data-source="KeycloakDS")

/subsystem=jgroups/stack=jdbcping/protocol=JDBC_PING/property=datasource_jndi_name:add(value="java:jboss/datasources/KeycloakDS")

/subsystem=jgroups/stack=jdbcping/protocol=JDBC_PING/property=initialize_sql:add(value="CREATE TABLE JGROUPSPING (own_addr varchar(200) NOT NULL, bind_addr varchar(200) NOT NULL, created timestamp NOT NULL, cluster_name varchar(200) NOT NULL, ping_data blob, constraint PK_JGROUPSPING PRIMARY KEY (own_addr, cluster_name))")
/subsystem=jgroups/stack=jdbcping/protocol=JDBC_PING/property=insert_single_sql:add(value="INSERT INTO JGROUPSPING (own_addr, bind_addr, created, cluster_name, ping_data) values (?,'${jgroups.bind.address:127.0.0.1}',NOW(), ?, ?)")
/subsystem=jgroups/stack=jdbcping/protocol=JDBC_PING/property=delete_single_sql:add(value="DELETE FROM JGROUPSPING WHERE own_addr=? AND cluster_name=?")
/subsystem=jgroups/stack=jdbcping/protocol=JDBC_PING/property=select_all_pingdata_sql:add(value="SELECT ping_data FROM JGROUPSPING WHERE cluster_name=?")
/subsystem=jgroups/stack=jdbcping/protocol=MERGE3:add
/subsystem=jgroups/stack=jdbcping/protocol=FD_SOCK:add(socket-binding=jgroups-tcp-fd)
/subsystem=jgroups/stack=jdbcping/protocol=FD:add
/subsystem=jgroups/stack=jdbcping/protocol=VERIFY_SUSPECT:add
/subsystem=jgroups/stack=jdbcping/protocol=pbcast.NAKACK2:add
/subsystem=jgroups/stack=jdbcping/protocol=UNICAST3:add
/subsystem=jgroups/stack=jdbcping/protocol=pbcast.STABLE:add
/subsystem=jgroups/stack=jdbcping/protocol=pbcast.GMS:add
/subsystem=jgroups/stack=jdbcping/protocol=MFC:add
/subsystem=jgroups/stack=jdbcping/protocol=FRAG2:add
/subsystem=jgroups/channel=ee:write-attribute(name=stack,value=jdbcping)
quit
```

#### Testing
Once you are done with either method above, start Keycloak on both nodes
```bash
/opt/keycloak-14.0.0/bin/standalone.sh --server-config=standalone-ha.xml --properties=/opt/jboss.properties
```

Verify that you see the below in the log
```plaintext
INFO  [org.infinispan.CLUSTER] (thread-5,ejb,keycloak1) ISPN000094: Received new cluster view for channel ejb: [keycloak1|1] (2) [keycloak1, keycloak2]
INFO  [org.infinispan.CLUSTER] (thread-14,ejb,keycloak2) [Context=authenticationSessions] ISPN100010: Finished rebalance with members [keycloak2, keycloak1], topology id 5
```

### Session Management
Now that the cluster is up, it's time to set up load balancing. According to the [Keycloak 14.0 Documentation](https://www.keycloak.org/docs/14.0/server_installation/#_clustering), Keycloak uses Inifispan to handle logged in sessions, so for performance reasons it's better to enable [sticky sessions](https://en.wikipedia.org/wiki/Load_balancing_(computing)#Persistence) on the load balancer. One drawback to the default configuration is if one node goes down all sessions handled by that node will be lost.

To solve this we need to increase the number of session owners. Create `session.cli`
```plaintext
embed-server --server-config=standalone-ha.xml

/subsystem=infinispan/cache-container=keycloak/distributed-cache=sessions:write-attribute(name=owners,value=${owner.count:1})
/subsystem=infinispan/cache-container=keycloak/distributed-cache=authenticationSessions:write-attribute(name=owners,value=${owner.count:1})
/subsystem=infinispan/cache-container=keycloak/distributed-cache=offlineSessions:write-attribute(name=owners,value=${owner.count:1})
/subsystem=infinispan/cache-container=keycloak/distributed-cache=clientSessions:write-attribute(name=owners,value=${owner.count:1})
/subsystem=infinispan/cache-container=keycloak/distributed-cache=offlineClientSessions:write-attribute(name=owners,value=${owner.count:1})
/subsystem=infinispan/cache-container=keycloak/distributed-cache=loginFailures:write-attribute(name=owners,value=${owner.count:1})
/subsystem=infinispan/cache-container=keycloak/distributed-cache=actionTokens:write-attribute(name=owners,value=${owner.count:1})

quit
```

Load the new session configuration.
```bash
/opt/keycloak-14.0.0/bin/jboss-cli.sh --file=session.cli
```

Add the line below to `/opt/jboss.properties`. Note that I kept the default session owner to 1.
```plaintext
owner.count=2
```

We also need to configure Keycloak to work behind a reverse proxy. Create `listener.cli`
```plaintext
embed-server --server-config=standalone-ha.xml

/subsystem=undertow/server=default-server/http-listener=default:write-attribute(name=proxy-address-forwarding, value=true)

quit
```

Update the http-listener configuration.
```bash
/opt/keycloak-14.0.0/bin/jboss-cli.sh --file=listener.cli
```

### HAProxy configuration
```bash
apt install haproxy
```

Edit `/etc/haproxy/haproxy.cfg`. Check out [this article]({{<relref "letsencrypt-prehooks.md">}}) to see how I set up certificates.
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

    # Generated using `openssl dhparam -out /etc/haproxy/dhparams.pem 2048`
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
    bind KEYCLOAK1_PUBLIC_IP:80
    bind KEYCLOAK1_PUBLIC_IP:443 ssl crt-list /etc/haproxy/certs alpn h2,http/1.1

    # LetsEncrypt
    acl acme path_dir /.well-known/acme-challenge

    http-response set-header Strict-Transport-Security max-age=15768000 if { ssl_fc }
    redirect scheme https code 301 if !{ ssl_fc } host_https !acme
    http-request set-header X-Forwarded-Proto https if  { ssl_fc }

    use_backend acme if acme

    default_backend keycloak

backend keycloak
    # Add the SERVERID cookie to allow sticky sessions
    cookie SERVERID insert indirect

    # LIGHT and DARK are just identifiers so the internal structure is not exposed. You can use different values
    server keycloak1 172.16.0.2:8080 check cookie LIGHT
    server keycloak2 172.16.0.3:8080 check cookie DARK

backend acme
    server acmetool 127.0.0.1:402
```

Reload HAProxy, Ubuntu starts it after installation by default
```bash
systemctl reload haproxy
```

### Startup script
Only thing left is to configure Keycloak as a service

```ini
[Unit]
Description=Keycloak Application Server
After=remote-fs.target syslog.target network.target

[Install]
WantedBy=multi-user.target

[Service]
User=jboss
Group=jboss
ExecStart=/opt/keycloak-14.0.0/bin/standalone.sh --server-config=standalone-ha.xml --properties=/opt/jboss.properties

Restart=on-failure
```

Now you can use [this article]({{<relref "keycloak-curl-script.md">}}) to generate tokens.
