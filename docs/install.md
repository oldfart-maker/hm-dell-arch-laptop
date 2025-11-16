SYSTEM INSTALL

* Step 1 - Create archlinux iso

Creat archlinux iso using balena (Download from archlinux.org/downloads)

***
* Step 2 - Start network

a) iwctl
b) device list
c) station wlan0 scan
d) station wlan0 get-networks
e) station wlan0 connect MySSID (Hangout)

***
* Step 3 - Boostrap archlinux

# a) mkdir -p ~/projects
b) cd ~/projects
c) git clone git@github.com:oldfart-maker/hm-dell-arch-laptop.git
# d) cp user_configuration.json ~/
e) cp user_credentials.json ~/
f) cp bootstrap.sh ~/
g) chmod +x bootstrap.sh
h) ./bootstrap.sh

***
* Step 4 - Run setup

a) git clone git@github.com:oldfart-maker/hm-dell-arch-laptop.git
b) cd ~/projects/hm-dell-arch-laptop/tools
c) chmod +x target-setup.sh
d) ./target-setup.sh
e) rm -rf hm-dell-arch-laptop
