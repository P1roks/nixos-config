{pkgs, ...}:
{
  imports = [
    ./eye.nix
    ./time.nix
    ./music.nix
    ./disk.nix
  ];

  systemd.user.services.dwmblocks = 
  let 
    dwmblocks = "${pkgs.dwmblocks}/bin/dwmblocks";
  in {
    enable = true;

    description = "interactive status bar for dwm";

    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    path = [ "/run/current-system/sw" ];

    serviceConfig = {
      ExecStart = dwmblocks;
      Restart = "always";
      RestartSec = 3;
    };
  };
  
  nixpkgs = {
    overlays = [
      (final: prev: {
        dwmblocks = (prev.dwmblocks.overrideAttrs {
          src = prev.fetchFromGitHub {
              owner = "torrinfail";
              repo = "dwmblocks";
              rev = "58a426b68a507afd3e681f2ea70a245167d3c3fb";
              sha256 = "CtDVb6/8/iktDkWnhIgi0Z3SyckZBCq5dsukFKEHahw=";
          };
        }).override {
          patches = [
            /etc/nixos/patches/dwmblocks.patch
          ];
          conf = ''
            static const Block blocks[] = {
                /*Icon*/ /*Command*/	/*Update Interval*/	/*Update Signal*/
                {"", "sb-music",			0,		11},
                {"", "sb-eye",			    0,      12},
                {"", "sb-time",             60,		1},
                {" ", "sb-disk",            0, 	13},
            };

            static char delim[] = " | ";
            static unsigned int delimLen = 5;
          '';
        };
      })
    ];
  };

  environment.systemPackages = with pkgs; [ dwmblocks ];
}
