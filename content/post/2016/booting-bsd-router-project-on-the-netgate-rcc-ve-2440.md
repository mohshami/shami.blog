---
title: Booting BSD Router Project On The Netgate RCC-VE 2440
date: 2016-06-30 09:22:04
categories:
  - FreeBSD
---
I have recently acquired a [Netgate RCC-VE 2440](http://store.netgate.com/ADI/RCC-VE-2440.aspx) which I intend to use as a router/firewall for my house. But I thought I might as well play with it a little before I do so. One of the things I wanted to test was the [BSD Router Project](http://bsdrp.net/) to have in place of one of the routers we have here at work but I couldn't get it to boot, it would always free with just a "\\".<!--more-->

After some searching I found the solution [here](https://forum.pfsense.org/index.php?topic=98761.0), which then led me to [this](https://www.netgate.com/docs/rcc-ve-4860/freebsd.html). Just follow the steps below (Valid for BSDRP 1.59)
1. Download the VGA version of BSDRP, not the serial one
2. Copy the image to a USB drive
3. Boot from the drive, and when you get the bootloader menu pause it quickly
4. Press "3" to escape to the boot loader menu
5. Enter the command `set comconsole_port=0x2F8`
6. Enter the command `boot -v`

At first you will notice that all characters will be printed twice but the boot process will proceed as normal after it leaves the bootloader menu.

After you're done with the installation you will need to do the same manually to get the system to boot the first time, then run the following commands
```bash
mount -uw /
echo 'comconsole_port="0x2F8"' >> /boot/loader.conf.local
echo 'comconsole_speed="115200"' >> /boot/loader.conf.local
echo 'hint.uart.0.flags=0x0' >> /boot/loader.conf.local
echo 'hint.uart.1.flags=0x10' >> /boot/loader.conf.local
echo 'console="comconsole"' >> /boot/loader.conf.local
echo '-h' > /boot.config
```

Then reboot, your Netgate should boot automatically now