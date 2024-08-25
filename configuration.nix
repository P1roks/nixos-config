{ pkgs, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
      ./home-manager
      ./nixvim.nix
      ./dwmblocks
      ./services.nix
      ./packages.nix
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
    users.piroks = {
      isNormalUser = true;
      shell = pkgs.fish;
      extraGroups = [ "wheel" "audio" ];
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
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
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
