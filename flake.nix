{
  inputs = {
    nixpkgs.url = "github:NixOs/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
    };
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    helium = {
      url = "github:schembriaiden/helium-browser-nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, nixvim,  ... }@inputs: {
    overlays = (import ./overlays.nix { }).nixpkgs.overlays
                ++ (import ./own-packages/default.nix { inherit (nixpkgs) pkgs; }).nixpkgs.overlays;

    nixosConfigurations = {
      legion = nixpkgs.lib.nixosSystem {
        system="x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          home-manager.nixosModules.home-manager
          nixvim.nixosModules.nixvim
          ./hosts/legion/default.nix
        ];
      };

      workstation = nixpkgs.lib.nixosSystem {
        system="x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          home-manager.nixosModules.home-manager
          nixvim.nixosModules.nixvim
          ./hosts/workstation/default.nix
        ];
      };
    };
  };
}
