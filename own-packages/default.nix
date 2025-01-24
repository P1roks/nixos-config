{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      nblood = pkgs.callPackage ./nblood.nix { inherit pkgs; };
      blood-picker = pkgs.callPackage ./blood-picker.nix { inherit pkgs; };
    })
  ];
}
