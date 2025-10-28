# home/modules/tools.nix
{ config, repoPath, ... }:
{
  home.file.".local/bin/hm-update" = {
    source = repoPath "home/scripts/hm-update.sh";
    executable = true;
  };
}
