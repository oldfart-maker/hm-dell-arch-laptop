SYSTEM INSTALL

* Step 1

Creat archlinux iso using balena (Download from archlinux.org/downloads)

***
* Step 2

Boot distro and connect network.
a) iwctl
b) device list
c) station wlan0 scan
d) station wlan0 get-networks
e) station wlan0 connect MySSID (Hangout)

****
* Step 3

a) pacman -Sy
b) pacman -S archinstall
c) archinstall (go through the wizard)
d) additional packages
	1. reflector
	\2. git
	3. base-devel
	4. xwayland-satellite
	
***
* Step 4

a) enable ssh: sudo systemctl enable sshd --now
b) login to host and start AFTER SYSTEM INSTALL docs



AFTER SYSTEM INSTALL
***
* Step 1 - Core install.

sh <(curl -L https://nixos.org/nix/install) --no-daemon
. ~/.nix-profile/etc/profile.d/nix.sh

***
* Step 2 - Home Manager install.

nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install

***
* Step 3 - Configure experimental feature to run remote build/switch flake.

mkdir -p ~/.config/nix
printf "experimental-features = nix-command flakes\n" > ~/.config/nix/nix.conf
. ~/.nix-profile/etc/profile.d/nix.sh
hash -r

***
* Step 4 - Run build/fetch with remote flake.

nix run nixpkgs#home-manager -- switch \
  --flake 'github:oldfart-maker/hm-dell-arch-laptop#username' -v

***
* Step 5 - Change the vterm-shell variable.

M-x set-variable, vterm-shell, "/bin/bash"
***
* Step 6 - Prime the wallpapers.

git clone https://github.com/greatbot6120/arch-wallpapers.git

***
* Step 7 - Copy api-keys.el to target (Run on host)

scp ~/.config/emacs-common/api-keys.el \
    username@192.168.1.108:~/.config/emacs-common/api-keys.el
