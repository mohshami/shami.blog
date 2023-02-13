---
date: 2017-11-06T12:10:12+02:00
title: "Installing Edx on Ubuntu Xenial"
Description: "Some text"
---

So I've been tasked with installing the [Open edX](https://open.edx.org/) devstack for work to do some testing. The current documentation is very lacking and it's been an ordeal. I decided to summerize the process as a reference.<!--more-->

**Note:** If you're installing on an OVH dedicated server, make sure to choose a custom installation with the original kernel and make sure the partition with /root has ample space.

**Note 2:** These instructions are based on the docs found [here](http://edx.readthedocs.io/projects/edx-installing-configuring-and-running/en/latest/installation/devstack/install_devstack.html)

### Update server
```bash
apt-get update
apt-get upgrade
apt-get dist-upgrade
reboot
```

### Install Vagrant and VirtualBox
```bash
apt-get install vagrant virtualbox # I noticed virtualbox components being installed with the script so virtualbox might not be necessary here
```

### Bootstrap
The document referenced above will tell you to download the box file before hand. I tried that but the installation script below downloaded another copy anway, so don't bother and leave it to the script

```bash
mkdir ~/devstack
cd ~/devstack
export OPENEDX_RELEASE=open-release/ginkgo.1 # Latest version at the time of writing
curl -OL https://raw.github.com/edx/configuration/$OPENEDX_RELEASE/util/install/install_stack.sh # Download bootstrap script
bash install_stack.sh devstack # Run the script
```

### If you get the following error

{{< thumbnail thumbnail="vagranterror.PNG" full="vagranterror.PNG" group="gallery">}}

Uninstall Vagrant and install from [here](https://www.vagrantup.com/downloads.html)

```bash
apt-get purge vagrant
dpkg -i /root/devstack/vagrant_2.0.1_x86_64.deb # Has to be the full path of the deb file or dpkg won't know what to do
bash install_stack.sh devstack # Run the script
```


https://github.com/edx/configuration/issues/2447