---
title: "Rrdtool Showing Squares Instead Of Letters In Graphs"
date: 2014-12-10 15:08:38
categories:
  - FreeBSD
---

Tried installing Cacti on FreeBSD today and got the following:<!--more-->
{{< thumbnail thumbnail="graph_image.png" full="graph_image.png" >}}

After some checks and trying to re-install the dejavu font like some forum posts suggested, I tried to generate the image manually

```bash
/usr/local/bin/rrdtool graph - --imgformat=PNG --start='-86400' --end='-300' --title='Localhost - Logged in Users' --rigid --base='1000' --height='120' --width='500' --alt-autoscale-max --lower-limit='0' --vertical-label='users' --slope-mode --font TITLE:10:'sans bold 8' --font AXIS:7: --font LEGEND:8: --font UNIT:7: DEF:a='/var/db/cacti/rra/localhost_users_6.rrd':'users':AVERAGE AREA:a#4668E4FF:'Users' GPRINT:a:LAST:'Current\:%8.0lf' GPRINT:a:AVERAGE:'Average\:%8.0lf' GPRINT:a:MAX:'Maximum\:%8.0lf\n' > image.png
```
I got the following error

```plaintext
(process:78048): Pango-CRITICAL **: No modules found:
No builtin or dynamically loaded modules were found.
PangoFc will not work correctly.
This probably means there was an error in the creation of:
  '/usr/local/etc/pango/pango.modules'
You should create this file by running:
  pango-querymodules > '/usr/local/etc/pango/pango.modules'

(process:78048): Pango-WARNING **: failed to choose a font, expect ugly output. engine-type='PangoRenderFc', script='common'

(process:78048): Pango-WARNING **: failed to choose a font, expect ugly output. engine-type='PangoRenderFc', script='latin'
```
Just run the following commands and you’ll be set
```bash
mkdir /usr/local/etc/pango/ 
pango-querymodules > '/usr/local/etc/pango/pango.modules'
```
