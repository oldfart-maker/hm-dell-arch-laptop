# home/modules/rclone.nix
{ config, pkgs, ... }:

let
  secretsRoot = "${config.home.homeDirectory}/projects/sys-secrets";
in
{
  home.packages = [ pkgs.rclone ];

  home.file.".config/rclone/rclone.conf" = {
    source = "${secretsRoot}/rclone/rclone.conf";
  };

  home.file.".config/rclone/officesync.filter" = {
    source = "${secretsRoot}/rclone/officesync.filter";
  };

  # optional assertion to catch timing mistakes
  assertions = [
    {
      assertion = builtins.pathExists "${secretsRoot}/rclone/rclone.conf";
      message   = "[rclone] Missing ${secretsRoot}/rclone/rclone.conf; did sys-secrets sync yet?";
    }
  ];
}
