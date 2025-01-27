{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      minecraft-font = pkgs.callPackage ./minecraft.nix { inherit pkgs; };
      vhs-font = pkgs.callPackage ./vhs.nix { inherit pkgs; };
    })
  ];
}
