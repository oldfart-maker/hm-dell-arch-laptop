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
* Step 2.5 - Install git
a) sudo pacman -Sy
b) sudo pacman -S git

***
* Step 3 - Boostrap archlinux

# a) mkdir -p ~/projects
b) cd ~/projects
c) git clone https://github.com/oldfart-maker/hm-dell-arch-laptop.git
d) cd /projects/hm-dell-arch-laptop/tools
e) ./bootstrap.sh
# 

***
* Step 4 - Run setup

a) mkdir -p ~/projects
b) cd ~/projects
c) git clone https://github.com/oldfart-maker/hm-dell-arch-laptop.git
c) git clone https://github.com/oldfart-maker/sys-secrets.git
e) cd ~/projects/hm-dell-arch-laptop/tools
f) chmod +x target-setup.sh
g) ./target-setup.sh
h) rm -rf hm-dell-arch-laptop
