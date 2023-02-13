---
date: 2021-06-24T10:02:48-04:00
title: "Logstash Hanging When Rebooting Ubuntu"
---

**Edit: 31/7/2022:** I'm currently migrating all my logstash configurations to [Vector](https://vector.dev), it has been much kinder to me than Logstash has ever been.

I maintain an ELK server running on Ubuntu 20.04 for testing. One issue I have faced is the Logstash service hanging on reboot. The server would not reboot and I end up having to power cycle.<!--more-->

It appears to be caused by the connection to Elasticsearch being severed when ElasticSearch is shut down before Logstash. One way to fix this is to make Elasticsearch a dependency of Logstash.

```bash
sudo systemctl edit logstash.service
```

```ini
[Unit]
After=elasticsearch.service
Requires=elasticsearch.service
```

This will make sure that Elasticsearch has to be started before starting Logstash, and more importantly will shut down Logstash before shutting down Elasticsearch. This has solved the issue for me.