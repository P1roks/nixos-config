{ pkgs, ... }:
{
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

    config = {
      allowUnfree = true;
    };
  };

  environment.systemPackages =
  with pkgs; [
    # nix related
    nix-tree
    # programming related
    gnumake
    libgcc
    rustup
    alacritty
    mycli
    # graphics
    gimp
    inkscape
    imagemagick
    # essential
    brave
    ranger
    neofetch
    rofi
    vesktop
    scrot
    dwmblocks
    # GPU
    vulkan-tools
    vulkan-loader
    vulkan-validation-layers
    vulkan-extension-layer
    mesa
    libva
    libva-utils
    # sound / music
    easyeffects
    pavucontrol
    mpc-cli
    mpv
    # utility
    calc
    redshift
    killall
    colorpicker
    copyq
    htop
    xdotool
    jmtpfs
    qbittorrent
    bat
    libnotify
    sxiv
    ripgrep
    # gaming
    heroic
    mangohud
    protonup
    # misc
    xclip
    ueberzugpp
    openssl
    libidn2
    libpsl
    nghttp2.lib
    p7zip
    # scripts
    (import ./scripts/blocks/music.nix)
    (import ./scripts/blocks/eye.nix)
    (import ./scripts/blocks/time.nix)
    (import ./scripts/screenshot.nix)
    (import ./scripts/books.nix)
    # "symlinks"
    (writeScriptBin "sudo" ''exec doas "$@"'')
    (writeScriptBin "podcast" ''mpc -p 6601 "$@"'')
    (writeScriptBin "dmenu" ''exec ${rofi}/bin/rofi -dmenu -i "$@"'')
  ];
}
