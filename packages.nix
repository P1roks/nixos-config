{ pkgs, ... }:
{
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };
  
  imports = [ ./scripts ];

  environment.systemPackages =
  with pkgs; [
    discord
    # nix related
    nix-tree
    nixpkgs-fmt
    # programming related
    gnumake
    libgcc
    cargo
    rustc
    nodejs
    lld
    gcc
    mycli
    sass
    jetbrains.pycharm-community-bin
    mitmproxy
    firefox
    # tex related
    (texliveBasic.withPackages (ps: with ps; [
      xcolor
      transparent
      collection-fontsrecommended
      hyperref
      etoolbox
    ]))
    # graphics
    gimp
    inkscape
    imagemagick
    lorien
    # essential
    alacritty
    brave
    ranger
    neofetch
    rofi
    vesktop
    scrot
    cryptsetup
    (builtins.getFlake "github:youwen5/zen-browser-flake").packages.${builtins.currentSystem}.default
    # word processing
    libreoffice-qt6-fresh
    hunspell
    hunspellDicts.en-us
    hunspellDicts.pl-pl
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
    pulsemixer
    alsa-utils
    # video
    ffmpeg-full
    obs-studio
    shotcut
    audacity
    # utility
    calc
    redshift
    killall
    xcolor
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
    xdragon
    pandoc
    poppler_utils
    # parsers
    jq
    yq
    htmlq
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
    #games
    prismlauncher
    packwiz
    # misc
    volantes-cursors
    xclip
    ueberzugpp
    openssl
    libidn2
    libpsl
    nghttp2.lib
    #scripts
    tag_album
    add_album
    read_book
    pshot
    volume_control
    brightness_control
    # "symlinks"
    (writeScriptBin "sudo" ''exec doas "$@"'')
    (writeScriptBin "podcast" ''mpc -p 6601 "$@"'')
    (writeScriptBin "dmenu" ''exec ${rofi}/bin/rofi -dmenu -i "$@"'')
  ];
}
