* Step 0 - Install niri.

sudo pacman -S niri

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
  --flake 'github:oldfart-maker/hm-pi5-arch-pi#username' -v

***
* Step 5 - Change the vterm-shell variable.

M-x set-variable, vterm-shell, "/bin/bash"
***
* Step 6 - Prime the wallpapers.

git clone https://github.com/greatbot6120/arch-wallpapers.git
