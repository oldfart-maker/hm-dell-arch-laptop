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
* Step 5 - Clone repo. (I'M NOT SURE WHY A LOCAL REPO IS NEEDED.)

mkdir -p ~/projects
git clone https://github.com/oldfart-maker/hm-pi5-arch-pi.git ~/projects/hm-pi5-arch-pi
