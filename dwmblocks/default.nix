{pkgs, ...}:
{
  imports = [
    ./eye.nix
    ./time.nix
    ./music.nix
  ];

  
  nixpkgs = {
    overlays = [
      (final: prev: {
        dwmblocks = prev.dwmblocks.overrideAttrs (finalAttrs: prevAttrs: {
            src = prev.fetchFromGitHub {
            owner = "torrinfail";
            repo = "dwmblocks";
            rev = "58a426b68a507afd3e681f2ea70a245167d3c3fb";
            sha256 = "CtDVb6/8/iktDkWnhIgi0Z3SyckZBCq5dsukFKEHahw=";
          };
          patches = [
            /etc/nixos/patches/dwmblocks.patch
          ];
        });
      })
    ];
  };

  environment.systemPackages = with pkgs; [ dwmblocks ];
}
