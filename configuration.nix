{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./home-manager
    ./nixvim.nix
    ./dwmblocks
    ./systemd.nix
    ./packages.nix
    ./machine.nix # this file is a symlink to a machine-specific config
  ];

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
    };

    settings = {
      experimental-features = [ "nix-command" "flakes" ];
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
  };

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 3;
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

  users = {
    users.piroks = {
      isNormalUser = true;
      shell = pkgs.fish;
      extraGroups = [ "wheel" "audio" "video" ];
    };
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

  environment.variables = {
    BROWSER = "brave";
    EDITOR = "nvim";
    TERMINAL = "alacritty";
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
