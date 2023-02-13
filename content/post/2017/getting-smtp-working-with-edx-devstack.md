---
date: 2017-11-22T11:50:09+02:00
title: "Getting Smtp Working With edX Devstack"
---

Lately I've been tinkering with [Open edX](https://open.edx.org/) at work for a project we're working on. The customer needed a specific workflow which required emails and all the parameters I found didn't help. But finally I found the solution [here](http://learning.perpetualny.com/blog/reliable-email-on-open-edx)<!--more-->

All I needed to do was add the following to `edx-platform/lms/envs/devstack.py`, this has to be added below the original EMAIL_BACKEND line
```none
EMAIL_BACKEND='django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST='MAIL_SERVER'
EMAIL_PORT=PORT
EMAIL_USE_TLS=TLS
EMAIL_HOST_USER='USERNAME'
EMAIL_HOST_PASSWORD='PASSWORD'
```

Restart LMS and you should be ready to go