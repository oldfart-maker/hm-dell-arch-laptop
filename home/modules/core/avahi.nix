{ config, pkgs, ... }:

{
  services.avahi = {
    enable = true;       # Avahi daemon
    nssmdns = true;      # Enable .local hostname resolution
  };
}
