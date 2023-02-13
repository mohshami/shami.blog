---
date: 2021-07-02T01:39:12-04:00
title: "Use A Raspberry Pi To Play The Adhan At Prayer Times"
draft: true
---

We moved from [Amman](https://en.wikipedia.org/wiki/Amman) to Ottawa about a year ago. In Amman all mosques broadcast a unified [Adhan](https://en.wikipedia.org/wiki/Adhan) which creates an ambiance that we have greatly missed here. The prayer time iOS apps that I downloaded don't let you set up a custom sound and the Android apps never worked. Frustrated enough, I finally decided to build this with a Raspberry Pi. I will share the the setup below.<!--more-->

### Hardware:
* [Raspberry Pi Zero W Budget Pack](https://www.buyapi.ca/product/raspberry-pi-zero-w-budget-pack/). I wanted to dedicate the Pi to this task and it doesn't need much processing power, so went with the cheapest option.
* [Mini External USB Stereo Speaker](https://www.buyapi.ca/product/mini-external-usb-stereo-speaker/)
* [AuviPal 3-Port Micro USB OTG Hub Adapter](https://www.amazon.ca/AuviPal-Adapter-Playstation-Classic-Raspberry/dp/B083WML1XB?pd_rd_w=g4JkT&pf_rd_p=faefa325-122d-49b7-9d82-54a6f4b0d47c&pf_rd_r=04S17TN85Z8BYBXQN1JF&pd_rd_r=82dcf525-d36e-4619-be99-7eb85de5ee31&pd_rd_wg=1JCgW&psc=1&ref_=pd_bap_d_csi_pd_ys_c_rfy_rp_crs_0_t). Needed because the Pi can't power on the speaker through USB. The bigger Pi might be able to power the speaker without an OTG hub but I haven't tested that myself.

I won't go through the full process to get the Pi set up. There are plenty of guides online. Just assemble the Pi and plug in the OTG hub in the USB port, then plug in the speaker and then the power supply. According to the Pi's schematics, the power and ground lines of the USB and power ports are connected, so the speakers and Pi can be powered off a single power supply. The power supply that came with the Pi is powerful enough so no need for an extra one.

Install Raspberry Pi OS and update to the latest version then follow the steps below.

```bash
# Install NodeJS and NPM
sudo apt install nodejs npm

# Install aplay and the Alsa volume mixer
apt-get install alsa-utils

# Create and initialize a NodeJS project
# This assumes the project will be located in /home/pi/adhancron
mkdir adhandcron
cd adhandcron
npm init -y     # We don't really care about the content here, so an empty project is fine

# The script uses the adhan NPM package, download and install
npm install adhan
```

Download the desired Adhan sound to /home/pi/adhancron/adhan.wav. Then test with running `aplay /home/pi/adhancron/adhan.wav`. Set the desired volume level and make sure everything is working manually before you proceed. Note that the file has to be encoded as WAV because that's what aplay can read.

Now add the content below to index.js. Make sure to substitute `LATITIDE` and `LONGITUDE` for your actual values
```javascript
'use strict';

const adhan = require('adhan')
const date = new Date();
const coordinates = new adhan.Coordinates(LATITIDE, LONGITUDE);

let params = adhan.CalculationMethod.NorthAmerica();
params.madhab = adhan.Madhab.Shafi;
const prayerTimes = new adhan.PrayerTimes(coordinates, date, params);

console.log("23 1 * * * /usr/bin/node /home/pi/adhancron/index.js | /usr/bin/crontab");

console.log("# Fajr");
console.log(`${prayerTimes.fajr.getUTCMinutes()} ${prayerTimes.fajr.getUTCHours()} * * * /usr/bin/aplay /home/pi/adhancron/adhan.wav`);

console.log("# Dhuhr");
console.log(`${prayerTimes.dhuhr.getUTCMinutes()} ${prayerTimes.dhuhr.getUTCHours()} * * * /usr/bin/aplay /home/pi/adhancron/adhan.wav`);

console.log("# Asr");
console.log(`${prayerTimes.asr.getUTCMinutes()} ${prayerTimes.asr.getUTCHours()} * * * /usr/bin/aplay /home/pi/adhancron/adhan.wav`);

console.log("# Maghrib");
console.log(`${prayerTimes.maghrib.getUTCMinutes()} ${prayerTimes.maghrib.getUTCHours()} * * * /usr/bin/aplay /home/pi/adhancron/adhan.wav`);

console.log("# Isha");
console.log(`${prayerTimes.isha.getUTCMinutes()} ${prayerTimes.isha.getUTCHours()} * * * /usr/bin/aplay /home/pi/adhancron/adhan.wav`);
```

Now just run `/usr/bin/node /home/pi/adhancron/index.js | /usr/bin/crontab` and you're done. This will set up the required scheduled task to update the prayer times on daily basis.