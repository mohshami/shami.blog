---
title: "Fix external display turning off when closing laptop lid with KDE and Wayland"
date: 2025-03-26T08:47:06-04:00
slug = 'fix-laptop-external-display-off'
---
I've been using NixOS with KDE Plasma 6.2 and Wayland lately, one weird issue I was running into was not being able to close the laptop lid when I connected to my thunderbolt dock.

I tested the following Nix configuration with no luck

```
services.logind = {
  lidSwitchExternalPower = "ignore";
  lidSwitchDocked = "ignore";
};
```
The issue turned out to be caused by KWin, the fix in my case was
* Log out of KDE (Your changes might be overwritten by KDE on log out, so better do this without KDE running)
* Log in using a terminal session
* Rename the kwinoutputconfig.json file `mv .config/kwinoutputconfig.json .config/kwinoutputconfig.json.org`
* Log back in to KDE

You will of course lose your monitor alignment and other configurations
