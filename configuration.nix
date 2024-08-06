{ config, pkgs, ... }:
let
    nixvim = import (builtins.fetchGit {
      url = "https://github.com/nix-community/nixvim";
      ref = "nixos-24.05";
    });
in
{
  imports =
    [
      <home-manager/nixos>
      nixvim.nixosModules.nixvim
      ./hardware-configuration.nix
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

    config = {
      allowUnfree = true;
    };
  };

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
    };

    settings = {
      experimental-features = [ "nix-command" ];
    };
  };

  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        vulkan-loader
        vulkan-validation-layers
        vulkan-extension-layer
      ];
    };

    printers = {
      ensurePrinters = [
        {
          name = "Lexmark_X364dn";
          location = "Home";
          deviceUri = "usb://Lexmark/X364dn?serial=35092YW&interface=1";
          model = "postscript-lexmark/Lexmark-X364dn-Postscript-Lexmark.ppd";
          ppdOptions = {
            PageSize = "A4";
          };
        }
      ];
    };
  };

  boot = {
    blacklistedKernelModules = [ "nouveau" ];
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 3;
        extraEntries."arch.conf" = "
          title Arch
          efi efi/GRUB/grubx64.efi
        ";
      };
      efi.canTouchEfiVariables = true;
    };
  };

  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
  };

  time.timeZone = "Europe/Warsaw";

  fonts = {
    packages = with pkgs; [
      iosevka
      noto-fonts
      nerdfonts
      google-fonts
    ];
    fontconfig = {
      defaultFonts = {
        monospace = ["Iosevka"];
        sansSerif = ["Iosevka"];
        serif = ["Iosevka"];
      };
    };
  };

  systemd.user.services = {
    copyq = {
      enable = true;

      name = "copyq";
      description = "copyq clipboard history";

      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.copyq}/bin/copyq";
        Restart = "always";
        RestartSec = 3;
      };
    };
  };

  services.xserver = {
    enable = true;
    xkb.layout = "pl";
    videoDrivers = [ "nvidia" ];
    xrandrHeads = [
      {
        output = "DP-0";
        primary = true;
        monitorConfig = ''
          HorizSync       242.0 - 242.0
          VertRefresh     48.0 - 165.0
          Option         "DPMS"
        '';
      }
      {
        output = "HDMI-0";
      }
    ];
    
    
    screenSection = ''
      Option         "metamodes" "DP-0: 2560x1440_165 +1920+0, HDMI-0: 1920x1080_60 +0+0"
      DefaultDepth    24
      Option         "Stereo" "0"
      Option         "nvidiaXineramaInfoOrder" "DFP-1"
      Option         "SLI" "Off"
      Option         "MultiGPU" "Off"
      Option         "BaseMosaic" "off"
    '';

    displayManager = {
      # TODO: Refactor all this to reproducible systemd services
      sessionCommands = ''
        dwmblocks &disown
        $(while :; do mpc idle; pkill -RTMIN+11 dwmblocks; done) &disown
      '';
    };

    windowManager.dwm = {
      enable = true;
      package = pkgs.dwm.overrideAttrs (finalAtrs: previousAttrs: {
        patches = [
          /etc/nixos/patches/dwm.patch
        ];
        buildInputs = previousAttrs.buildInputs ++ [pkgs.imlib2];
      });
    };

    desktopManager.wallpaper.combineScreens = true;
  };

  services.printing = {
    enable = true;
    drivers = with pkgs; [
      postscript-lexmark
    ];
  };
  
  services.picom = {
    enable = true;
  };

  # Enable sound.
  security = {
    rtkit.enable = true;
    sudo.enable = false;

    doas = {
      enable = true;
      extraRules = [{
        groups = [ "wheel" ];
        persist = true;
        keepEnv = true;
      }];
    };
  };

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
  };

  users = {
    defaultUserShell = pkgs.fish;
    users.piroks = {
      isNormalUser = true;
      shell = pkgs.fish;
      extraGroups = [ "wheel" "audio" ];
    };
  };

  environment.variables = rec {
    BROWSER = "brave";
    EDITOR = "nvim";
    TERMINAL = "alacritty";
    VK_DRIVER_FILES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json:/run/opengl-driver-32/share/vulkan/icd.d/nvidia_icd.i686.json";
    VK_ICD_FILENAMES = VK_DRIVER_FILES;
    __GL_SYNC_DISPLAY_DEVICE = "DP-0";
    __GL_SYNC_TO_VBLANK = 0;
    __GL_GSYNC_ALLOWED = 0;
  };

  programs = {
    dconf.enable = true;
    gamemode.enable = true;
    fish.enable = true;
    git = {
      enable = true;
      config = {
        init = { defaultBranch = "main"; }; 
      };
    };

    steam = {
      enable = true;
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
  };

  programs.nixvim = {
    enable = true;
    enableMan = true;
    vimAlias = true;

    colorschemes.gruvbox.enable = true;

    opts = {
      number = true;
      relativenumber = true;
      ignorecase = true;
      smartcase = true;
      showmode = false;
      tabstop = 4;
      shiftwidth = 4;
      expandtab = true;
    };

    autoCmd = [
      # nix config files have 2-width tabs
      {
        event = ["Filetype"];
        pattern = ["nix"];
        command = "setlocal tabstop=2 shiftwidth=2";
      }
    ];

    plugins = {
      nvim-autopairs.enable = true;
      indent-blankline = {
        enable = true;

        settings = {
          indent.tab_char = "⇥";
        };
      };

      lualine = {
        enable = true;
        theme = "gruvbox-material";
        sections = {
          lualine_x = [ "encoding" "filetype" ];
        };
      };

      treesitter = {
        enable = true;
        nixGrammars = true;
        nixvimInjections = true;
        ensureInstalled = [
          "diff" "dockerfile" "awk"
          "bash" "fish" "nix"
          "yaml" "toml" "json"
          "html" "css" "scss"
          "javascript" "typescript" "tsx"
          "c" "cpp" "rust"
          "kotlin" "scala" "java"
          "make" "cmake"
        ];
      };

      telescope = {
        enable = true;
        keymaps = {
            "<c-p>".action = "find_files";
        };
      };

      cmp-vsnip.enable = true;
      cmp = {
        enable = true;
        settings = {

          sources = [
            { name = "nvim_lsp"; }
            { name = "vsnip"; }
            { name = "buffer"; }
          ];

          snippets.expand = ''
            function(args)
              vim.fn["vsnip#anonymous"](args.body)
            end
          '';
        };
      };

      lsp = {
        enable = true;
        servers = {
          clangd.enable = true;
          tsserver.enable = true;
          nixd.enable = true;
          bashls.enable = true;
          #rust-analyzer = {
          #  enable = true;
          #};
        };
      };
    };

    extraPlugins = with pkgs.vimPlugins; [
      {
        plugin = nvim-surround;
        config = ''lua require("nvim-surround").setup({})'';
      }
    ];
  };

  home-manager.useGlobalPkgs = true;

  home-manager.users.piroks = { pkgs, ... }:
  let
    home = config.users.users.piroks.home;
  in
  {
    xsession = {
      enable = true;
      numlock.enable = true;
      initExtra = with pkgs; ''
        ${xorg.xset}/bin/xset r rate 300 40
        $(${coreutils}/bin/sleep 1 && ${xorg.xsetroot}/bin/xsetroot -cursor_name left_ptr) &
      '';
    };


    services.mpd =
    {
      enable = true;
      musicDirectory = "${home}/Music";
      dataDir = "${home}/.config/mpd";
      extraConfig = ''
        audio_output {
          type "pulse"
          name "Sound server"
        }
      '';
    };

    programs.git = {
      enable = true;
      userName = "P1roks";
      userEmail = "piotrekjakobczyk1@gmail.com";
    };

    programs.fish = {
      enable = true;

      shellInit = ''
        set fish_greeting ""
        fish_vi_key_bindings
      '';
      
      plugins = [
        {
          name = "nix";
          src = pkgs.fetchFromGitHub {
            owner = "kidonng";
            repo = "nix.fish";
            rev = "ad57d970841ae4a24521b5b1a68121cf385ba71e";
            sha256 = "GMV0GyORJ8Tt2S9wTCo2lkkLtetYv0rc19aA5KJbo48=";
          };
        }
        {
          name = "autopair";
          src = pkgs.fetchFromGitHub {
            owner = "jorgebucaran";
            repo = "autopair.fish";
            rev = "4d1752ff5b39819ab58d7337c69220342e9de0e2";
            sha256 = "qt3t1iKRRNuiLWiVoiAYOu+9E7jsyECyIqZJ/oRIT1A=";
          };
        }
      ];

      shellAliases = {
        nix-edit = "doas \$EDITOR /etc/nixos/configuration.nix";
      };
    };

    gtk = {
      enable = true;
      theme = {
        name = "Adwaita-dark";
        package = pkgs.gnome.gnome-themes-extra;
      };
    };

    home = {
      pointerCursor = {
        package = pkgs.volantes-cursors;
        name = "volantes_light_cursors";
        gtk.enable = true;
        x11.enable = true;
      };
      sessionVariables = {
        STEAM_EXTRA_COMPAT_TOOLS_PATHS = "${home}/.steam/root/compatibilitytools.d";
      };
    };
    
    home.stateVersion = "24.05"; # DON'T CHANGE
  };

  # Packages installed
  environment.systemPackages =
  with pkgs; [
    # nix related
    nix-tree
    # programming related
    gnumake
    libgcc
    rustup
    gh
    git
    alacritty
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
    gscreenshot
    zathura
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
    # "symlinks"
    (writeScriptBin "sudo" ''exec doas "$@"'')
    (writeScriptBin "dmenu" ''exec ${rofi}/bin/rofi -dmenu -i "$@"'')
  ];

  system.stateVersion = "24.05"; # DON'T CHANGE
}

