{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      minecraft-font = pkgs.callPackage ./minecraft.nix { inherit pkgs; };
    })
  ];
}
