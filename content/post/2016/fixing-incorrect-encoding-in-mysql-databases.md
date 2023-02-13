---
title: Fixing Incorrect Encoding In MySQL Databases
date: 2016-05-26 12:36:45
categories:
  - MySQL
---

I have recently faced an issue while migrating MySQL to a new server where non-English characters show up as gibberish. This was because UTF-8 text was saved in columns encoded as latin1. The solution is simple, convert the field into a BLOB and then back to text with the required type and encoding.<!--more-->

Sometimes you need to do that multiple times, if you do, you need to convert the table back to latin1 and then do the procedure again

```sql
ALTER TABLE _TABLE MODIFY _TABLE.field BLOB;
ALTER TABLE _TABLE MODIFY _TABLE.field VARCHAR(200) CHARACTER SET utf8;

/* if you have to do this a second time*/
ALTER TABLE _TABLE MODIFY _TABLE.field VARCHAR(200) CHARACTER SET latin1;
ALTER TABLE _TABLE MODIFY _TABLE.field BLOB;
ALTER TABLE _TABLE MODIFY _TABLE.field VARCHAR(200) CHARACTER SET utf8;
```