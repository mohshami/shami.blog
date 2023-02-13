---
title: "Moving A Magento Instance To A New Domain"
date: 2016-04-21 13:21:20
categories:
  - Technical
---

Quick one here, when you move a Magento instance to a new domain or URL it will keep redirecting to the old address. There is a quick fix<!--more-->

```sql
update core_config_data set value='https://NEW_DOMAIN/' where path='web/secure/base_url';
update core_config_data set value='http://NEW_DOMAIN/' where path='web/unsecure/base_url';
```

Just make sure you include a slash at the end of the new domain name