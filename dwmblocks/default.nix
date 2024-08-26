{pkgs, ...}:
{
  imports = [
    ./eye.nix
    ./time.nix
    ./music.nix
    ./disk.nix
    ./service.nix
  ];

  services.dwmblocks = {
    enable = true;

    package = pkgs.dwmblocks.overrideAttrs {
       src = pkgs.fetchFromGitHub {
         owner = "torrinfail";
         repo = "dwmblocks";
         rev = "58a426b68a507afd3e681f2ea70a245167d3c3fb";
         sha256 = "CtDVb6/8/iktDkWnhIgi0Z3SyckZBCq5dsukFKEHahw=";
       };
    };

    patches = [
      /etc/nixos/patches/dwmblocks.patch
    ];

    blocks = [
      {
        command = "sb-music";
        signal = 11;
      }
      {
        command = "sb-eye";
        signal = 12;
      }
      {
        command = "sb-time";
        interval = 60;
        signal = 1;
      }
      {
        icon = " ";
        command = "sb-disk";
        signal = 13;
      }
    ];

  };

}
