---
date: 2017-10-26T14:25:50+03:00
title: "Bad Gateway With Nginx, PHP, and Oracle"
---

So I got a call from one of our developers telling me one of our Moodle development sites was not working. This particular Moodle instance was configured to use an Oracle backend since that's what the customer has. Upon checking I got a "Bad Gateway" error.<!--more-->

PHP was up and running, Nginx was configured correctly. The site has been working for a few weeks now and nothing has changed. After a few restarts and trying to tweak the configuration I reached a dead end, but then decided to try a phpinfo() page, to my surprise that worked.

So the problem was Moodle related, not PHP and Nginx. After some checking, the problem was in `/lib/dmllib.php` at line 345

```php
$DB->connect($CFG->dbhost, $CFG->dbuser, $CFG->dbpass, $CFG->dbname, $CFG->prefix, $CFG->dboptions);
```

Then I tried to log in to the database and got this

{{< thumbnail thumbnail="oracle_error.jpg" group="gallery">}}

After updating the password and setting it to never expire the site went to working again. Seems Oracle support is still not mature enough in PHP.

PHP version used was 7.0.15 on Ubuntu 16.04 LTS with Oracle Instant Client basic 10.1.0.5.0-20060519.