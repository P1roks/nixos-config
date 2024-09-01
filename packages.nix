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
    mycli
    # graphics
    gimp
    inkscape
    imagemagick
    # essential
    alacritty
    brave
    ranger
    neofetch
    rofi
    vesktop
    libreoffice-qt6-fresh
    scrot
    cryptsetup
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
    ncmpcpp
    python312Packages.mutagen
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
    # archives
    p7zip
    unrar
    unzip
    atool
    # gaming
    heroic
    mangohud
    protonup
    lutris
    # misc
    volantes-cursors
    xclip
    ueberzugpp
    openssl
    libidn2
    libpsl
    nghttp2.lib
    # scripts
    (import ./scripts/screenshot.nix)
    (import ./scripts/books.nix)
    (import ./scripts/add-album.nix)
    (import ./scripts/tag-album.nix)
    # "symlinks"
    (writeScriptBin "sudo" ''exec doas "$@"'')
    (writeScriptBin "podcast" ''mpc -p 6601 "$@"'')
    (writeScriptBin "dmenu" ''exec ${rofi}/bin/rofi -dmenu -i "$@"'')
  ];
}
