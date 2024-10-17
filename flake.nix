{
  description = "NixOS configs for my machines";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # NixOS profiles to optimize settings for different hardware
    hardware.url = "github:nixos/nixos-hardware";

    # Global catppuccin theme
    catppuccin.url = "github:catppuccin/nix";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    catppuccin,
    ...
  } @ inputs: let
    inherit (self) outputs;

    # Define user configurations
    users = {
      xvitcoder = {
        email = "xvitcoder@gmail.com";
        fullName = "Vitalie Mudrenco";
        gitKey = "0xEFA1076BB814FD09";
        name = "xvitcoder";
      };
    };

    # Function for NixOS system configuration
    mkNixosConfiguration = hostname: username:
      nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs hostname;
          userConfig = users.${username};
        };
        modules = [./hosts/${hostname}/configuration.nix];
      };

    # Function for Home Manager configuration
    mkHomeConfiguration = system: username: hostname:
      home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {inherit system;};
        extraSpecialArgs = {
          inherit inputs outputs;
          userConfig = users.${username};
        };
        modules = [
          ./home/${username}/${hostname}.nix
          catppuccin.homeManagerModules.catppuccin
        ];
      };
  in {
    nixosConfigurations = {
      workstation = mkNixosConfiguration "workstation" "xvitcoder";
      thinkpad = mkNixosConfiguration "workstation" "xvitcoder";
      virtualbox = mkNixosConfiguration "virtualbox" "xvitcoder";
    };

    homeConfigurations = {
      "xvitcoder@workstation" = mkHomeConfiguration "x86_64-linux" "xvitcoder" "workstation";
      "xvitcoder@thinkpad" = mkHomeConfiguration "x86_64-linux" "xvitcoder" "thinkpad";
      "xvitcoder@virtualbox" = mkHomeConfiguration "x86_64-linux" "xvitcoder" "virtualbox";
    };

    overlays = import ./overlays {inherit inputs;};
  };
}
