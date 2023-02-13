---
title: Some Gnome Key Binding Tips
date: 2008-04-08 03:20:19
categories:
  - Technical
url: /2008/04/tips-for-keyboard-shortcuts-under-gnome
---

A few days ago I decided to bite the bullet and upgrade from Ubuntu 7.04 to 8.04. I've been using IceWM for a while and thought I should give Gnome a try. I'm used to Win+Something shortcuts so I wanted to implement those under Gnome. Here is a list of shortcuts that should cover the concepts:<!--more-->

A few days ago I decided to bite the bullet and upgrade from Ubuntu 7.04 to 8.04. I've been using IceWM for a while and thought I should give Gnome a try. I'm used to Win+Something shortcuts so I wanted to implement those under Gnome. Here is a list of shortcuts that should cover the concepts:

- Win+Q: Terminal (With some specific options)
- Control+Alt+W: Amarok (The W is from my Windows days, from Winamp :) )
- Alt+F5: Toggle window maximized mode
- Win+[ZXCVB]: Playback controls for Amarok
- Win+R: Run dialog

Let's begin

- Open gconf-editor and go to global_keybindings.As you can see the format isn't hard
- Set the value of run_command_1 to "<Super>q" and the value of run_command_2 to "<Alt><Control>w" without the quotes (Those correspond to Win+Q and Control+Alt+W)
- Now go to keybinding_commands
- Set the value of command_1 to "xterm -ls -fg white -bg black -cc 33:48,37:48,45-47:48,38:48,58:48" and the value of command_2 to "amarok" without the quotes. Now test Win+Q and Control+Alt+W
- Go to windows_keybindings
- Set the value of toggle_maximized to "<Alt>F5". Now test
- Run dialog is set using panel_run_dialog under global_keybindings, I set it to "<Super>r". Amarok sets the playback keys by default, but you'll notice that both Win+R and Win+V don't work. This happens because Compiz is the default window manager now. To fix this install compizconfig-settings-manager, go to "Advanced Desktop Effects Settings" and disable "Enhanced Zoom Desktop" or change the key bindings. This will free both key bindings so you can use them here

**Edit:** A weird thing happened to me today, I set the "Visual Effects" in appearance to "None" and suddenly my shortcuts stopped working. The solution to this is simple, make sure you use "<Super>r", not "<Super> R"; Note the extra space before the "R". Omitting this space works in both cases, something to keep in mind.