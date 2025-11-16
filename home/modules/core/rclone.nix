# home/modules/rclone.nix
{ config, pkgs, lib, ... }:

let
  secretsRoot = "${config.home.homeDirectory}/projects/sys-secrets";
in
{
  home.packages = [ pkgs.rclone ];

  home.file.".config/rclone/rclone.conf".source =
    mkSecret "${secretsRoot}/rclone/rclone.conf";

  home.file.".config/rclone/officesync.filter".source =
    mkSecret "${secretsRoot}/rclone/officesync.filter";    
}
