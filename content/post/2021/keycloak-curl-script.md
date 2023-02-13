---
date: 2021-07-09T14:42:39-04:00
title: "Generate Keycloak Access Tokens with Curl"
---

I've been working more with [Keycloak](https://www.keycloak.org/) lately and I'm loving it. But one thing I wanted to do while testing is to generate access tokens easily. Today I wrote a small wrapper script and thought I should share.<!--more-->

```bash
#!/bin/sh

set -e

HOST=`cat $1 | jq -r .host`
REALM=`cat $1 | jq -r .realm`
USERNAME=`cat $1 | jq -r .username`
PASSWORD=`cat $1 | jq -r .password`
CLIENTID=`cat $1 | jq -r .clientid`
CLIENTSECRET=`cat $1 | jq -r .client_secret`

curl -X POST \
    https://$HOST/auth/realms/$REALM/protocol/openid-connect/token \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    -d username=$USERNAME \
    -d password=$PASSWORD \
    -d grant_type=password \
    -d client_id=$CLIENTID \
    -d client_secret=$CLIENTSECRET
```

The script takes a single JSON file as input and uses the information inside to generate the token. The reason why I went with this approach rather than simple command line parameters is to enable me to quickly switch between Keycloak installations and realms.

Sample JSON file
```json
{
  "host": "auth.localtest.me",
  "realm": "realm_name",
  "username": "user_name",
  "password": "super_secret_password",
  "clientid": "client_id",
  "client_secret": "client_secret"
}
```

[localtest.me](http://readme.localtest.me) is a cool service I discovered last night. \*.localtest.me will resolve to localhost so you won't have to fiddle with the hosts file for local development. The only downside to that is you will have to use a self signed certificate which requires modifying the script and adding the `--insecure`  flag to curl.

To generate the token simply run
```bash
./keycloak-curl.sh file.json
```