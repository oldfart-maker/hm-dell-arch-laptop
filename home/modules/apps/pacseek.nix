{ pkgs, lib }:

pkgs.buildGoModule rec {
  pname = "pacseek";
  version = "1.8.5";

  src = pkgs.fetchFromGitHub {
    owner = "moson-mo";
    repo  = "pacseek";
    rev   = "v${version}";


    hash  = "sha256-df6XIqdQJcx+Aesoh6+iXEWlKc/fbB2FZMK7v1S1ZF0=";
    
  };


  vendorHash = "sha256-df6XIqdQJcx+Aesoh6+iXEWlKc/fbB2FZMK7v1S1ZF0=";

  ldflags = [ "-s" "-w" ];

  meta = with lib; {
    description = "A terminal UI for searching and installing Arch Linux and AUR packages";
    homepage    = "https://github.com/moson-mo/pacseek";
    license     = licenses.mit;
    platforms   = platforms.linux;
  };
}
