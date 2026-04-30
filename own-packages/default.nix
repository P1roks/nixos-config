{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      nblood = final.callPackage ./nblood.nix { inherit pkgs; };
    })
    (final: prev: {
      notblood = final.callPackage ./notblood.nix { inherit pkgs; };
    })
    (final: prev: {
      gemini-cli-bin-own = final.callPackage ./gemini-cli-own.nix { inherit pkgs; };
    })
  ];
}
