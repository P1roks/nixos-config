{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  
  imports = [ ./scripts ];

  environment.systemPackages =
  with pkgs; [
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
    sass
    # web hacking
    mitmproxy
    insomnia
    firefox
    # tex related
    (texliveBasic.withPackages (pkgs: with pkgs; [
      xcolor
      transparent
      collection-fontsrecommended
      hyperref
      etoolbox
    ]))
    # databases
    mycli
    # graphics
    gimp
    inkscape
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
    # note-taking / thinking
    obsidian
    lorien
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
    mpc
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
    dragon-drop
    pandoc
    poppler-utils
    imagemagick
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
    protonup-ng
    lutris
    #games
    prismlauncher
    packwiz
    nblood
    blood_picker
    # misc
    xclip
    ueberzugpp
    openssl
    libidn2
    libpsl
    nghttp2.lib
    geteduroam
    #scripts
    tag_album
    add_album
    read_book
    pshot
    volume_control
    brightness_control
    spawn_session_shell
    # "symlinks"
    (writeScriptBin "sudo" ''exec doas "$@"'')
    (writeScriptBin "podcast" ''mpc -p 6601 "$@"'')
    (writeScriptBin "dmenu" ''exec ${rofi}/bin/rofi -dmenu -i "$@"'')
  ];
}
