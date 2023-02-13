---
date: 2017-06-22T11:10:25+03:00
title: "Nvidia Drivers On Headless Ubuntu Server 16.04"
---
I wanted to do some GPU processing using a virtual machine running inside [unRAID](https://lime-technology.com/). First I tried Windows and it worked, but I read that running the code inside Ubuntu 16.04 would be more efficient.<!--more-->

So I installed Ubuntu Server and tried to install the Nvidia drivers using apt-get and it installed a LOT of dependencies, so I stopped it and went for Ubuntu Desktop which turned out to be indeed more efficient than Windows.

Last night my son hit the power button on my unRAID box and shut down all virtual machines. I booted the VM but realized I can't log in via VNC because I don't have a monitor connected to my graphics card. I decided to go back to Ubuntu Server and see what I can do.

Finally, found the solution [here](https://askubuntu.com/questions/830983/how-to-winstall-nvidia-drivers-to-use-cuda-without-also-installing-x11). Just download the CUDA drivers from [here](https://developer.nvidia.com/cuda-downloads) and run the binary file; "cuda_8.0.61_375.26_linux-run" at the time of writing. It will install the needed driver for you.

Now I can run my code inside tmux like servers were intended to be run :)