{ pkgs, ... }:
{
  home.packages = with pkgs; [
    reflector
  ];
}
