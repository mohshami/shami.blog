---
date: "2017-03-16"
title: "No Output From Drush"
categories:
  - Technical
---

A while back [Drush](https://github.com/drush-ops/drush) stopped working on my servers and it would just return without doing anything. Today I decided to finally debug the issue. Turns out the FreeBSD port just fetches the [Phar](http://php.net/manual/en/phar.using.intro.php) archive and installs it.

After digging around I found the [following post](http://stackoverflow.com/questions/19925526/using-cli-to-use-phar-file-not-working) which says that [Suhosin](https://suhosin.org/stories/index.html) blocks Phar file execution. The fix turned out to be quite simple; Just edit the Suhosin ini file (in FreeBSD it's /usr/local/etc/php/ext-30-suhosin.ini) and add the following after the "extension" line:

```none
suhosin.executor.include.whitelist = phar
```

And you’re back in business :)
<!--more-->
