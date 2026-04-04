{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      nblood = pkgs.callPackage ./nblood.nix { inherit pkgs; };
    })
    (final: prev: {
      notblood = pkgs.callPackage ./notblood.nix { inherit pkgs; };
    })
  ];
}
