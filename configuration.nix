{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./home-manager
    ./nixvim.nix
    ./dwmblocks
    ./fonts
    ./own-packages
    ./systemd.nix
    ./packages.nix
    ./machine.nix # this file is a symlink to a machine-specific config
  ];

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      persistent = true;
    };

    settings = {
      experimental-features = [ "nix-command" "flakes" ];
    };
  };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        vulkan-loader
        vulkan-validation-layers
        vulkan-extension-layer
      ];
    };
  };

  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 3;
    };
    efi.canTouchEfiVariables = true;
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
      google-fonts
      minecraft-font
      vhs-font
    ] ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
    fontconfig = {
      defaultFonts = {
        monospace = ["Iosevka"];
        sansSerif = ["Iosevka"];
        serif = ["Iosevka"];
      };
    };
  };

  services.xserver = {
    enable = true;
    xkb.layout = "pl";

    windowManager.dwm = {
      enable = true;
      package = pkgs.dwm.overrideAttrs (finalAtrs: previousAttrs: {
        patches = [
          /etc/nixos/patches/dwm.patch
        ];
        buildInputs = previousAttrs.buildInputs ++ [pkgs.imlib2];
        version = "6.5";
        src = builtins.fetchurl {
          url = "https://dl.suckless.org/dwm/dwm-6.5.tar.gz";
          sha256 = "sha256-Ideev6ny+5MUGDbCZmy4H0eExp1k5/GyNS+blwuglyk=";
        };
      });
    };

    desktopManager.wallpaper.combineScreens = true;
  };

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

  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocales = [ "en_GB.UTF-8/UTF-8" "pl_PL.UTF-8/UTF-8" "de_DE.UTF-8/UTF-8" ];
    extraLocaleSettings = {
      LC_MEASUREMENT="pl_PL.UTF-8";
      LC_TIME="pl_PL.UTF-8";
      LC_ADDRESS="pl_PL.UTF-8";
      LC_MONETARY="pl_PL.UTF-8";
      LC_TELEPHONE="pl_PL.UTF-8";
      LC_CTYPE="en_US.UTF-8";
      LC_NUMERIC="en_US.UTF-8";
      LC_COLLATE="en_US.UTF-8";
      LC_MESSAGES="en_US.UTF-8";
      LC_PAPER="en_US.UTF-8";
      LC_NAME="en_US.UTF-8";
      LC_IDENTIFICATION="en_US.UTF-8";
    };
  };

  services.libinput = {
    enable = true;
    mouse = {
      # this defaulting to true is stupid
      middleEmulation = false;
    };
  };
  
  services.picom = {
    enable = true;
  };

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

  users.users = {
    piroks = {
      isNormalUser = true;
      shell = pkgs.fish;
      extraGroups = [ "wheel" "audio" "video" "networkmanager"];
    };
  };

  environment.variables = {
    BROWSER = "zen";
    EDITOR = "nvim";
    TERMINAL = "alacritty";
  };

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    ensureUsers = [
      {
        name = "piroks";
        ensurePermissions = {
          "*.*" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  programs = {
    dconf.enable = true;
    gamemode.enable = true;
    fish.enable = true;

    git = {
      enable = true;
      config = {
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
        safe.directory = "/etc/nixos";
        pull.rebase = true;
      };
    };

    steam = {
      enable = true;
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
  };

  system.stateVersion = "24.05"; # DON'T CHANGE
}
