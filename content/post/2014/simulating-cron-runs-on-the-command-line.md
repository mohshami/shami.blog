---
title: "Simulating Cron Runs On The Command Line"
date: 2014-10-15 10:23:31
categories:
  - FreeBSD
---

Does this sound familiar?

You write a new script, start it from the command line, everything works properly, you add that script to your crontab then go home, the next day, nothing. So you end up setting up a schedule to run this script the next minute, the script fails, you change something, update the schedule, rinse and repeat. <!--more-->

This has bitten me more times than I dare confess. So I thought I should find a way to simulate running the script inside cron. The main difference between running a script directly or having it run through cron is the environment, and the lack of interactive shell. So simulating this is easy, just run the following command:
```bash
env -i USER=$USER HOME=$HOME LOGNAME=$LOGNAME PATH=/usr/bin:/bin SHELL=/bin/sh PWD=$HOME YOUR_SCRIPT_HERE
```

This builds a very minimal environment and runs the command there. This has helped me find an issue with a new Python script I deployed today.

Another thing you can do is write a small script that dumps the output of env to a file, run this script through cron and use the generated values instead of the ones in the snippet above

Hope it helps someone.