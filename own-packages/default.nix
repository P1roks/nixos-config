{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      nblood = pkgs.callPackage ./nblood.nix { inherit pkgs; };
    })
  ];
}
