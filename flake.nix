{
  description = "Home Manager for Pi (Arch)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, stylix, ... }:
  let
    system = builtins.currentSystem or "aarch64-linux";    
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    homeConfigurations.username =
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          stylix.homeManagerModules.stylix
          ./home/home.nix
        ];

        extraSpecialArgs = {
          inherit self stylix paths;
          inputs = { inherit self stylix nixpkgs home-manager; };
        };
      };
  };
}
