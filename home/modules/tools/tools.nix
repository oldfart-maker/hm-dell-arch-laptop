# home/modules/tools.nix
{ config, ... }:
{
  # Ensure ~/.local/bin exists and script is linked, executable
  home.file.".local/bin/hm-update" = {
    source = repoPath "home/modules/tools/hm-update.sh;
    executable = true;
  };
}
