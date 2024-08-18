{ pkgs, ... }:
{
  nixpkgs = {
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
    element-desktop
    scrot
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
    yt-dlp
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
    (import ./scripts/screenshot.nix)
    (import ./scripts/books.nix)
    # "symlinks"
    (writeScriptBin "sudo" ''exec doas "$@"'')
    (writeScriptBin "podcast" ''mpc -p 6601 "$@"'')
    (writeScriptBin "dmenu" ''exec ${rofi}/bin/rofi -dmenu -i "$@"'')
  ];
}
