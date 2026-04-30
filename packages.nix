{ pkgs, inputs, ... }:
let
 texLive =  
    pkgs.texliveMedium.withPackages (pkgs: with pkgs; [
      xcolor
      transparent
      collection-fontsrecommended
      collection-langenglish
      collection-langpolish
      hyperref
      etoolbox
      amsmath
      hypcap
      latex-uni8
      babel
      float
      listingsutf8
      upquote
      lineno
      fvextra
      catchfile
      xstring
      framed
      fancyvrb
      ifplatform
      pdftexcmds
      kvoptions
      latexmk
      luatex
      piton
    ]);
in 
{
  nixpkgs.config.allowUnfree = true;
  
  imports = [ ./scripts ];

  environment.systemPackages =
  with pkgs; with inputs; [
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
    texLive
    # databases
    mycli
    # graphics
    gimp
    inkscape
    # essential
    brave
    ranger # TODO: investigate changing to yazi
    neofetch
    rofi
    vesktop
    signal-desktop
    scrot
    cryptsetup
    zen-browser.packages.${pkgs.system}.default
    helium.packages.${pkgs.system}.default
    gemini-cli-bin-own
    pass
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
    python313Packages.mutagen
    python313Packages.pygments
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
    rars
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
    notblood
    blood_picker
    # misc
    xclip
    ueberzugpp
    openssl
    libidn2
    libpsl
    nghttp2.lib
    geteduroam
    quarto
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

  # programs.nixvim.plugins.vimtex.texlivePackage = texLive;
}
