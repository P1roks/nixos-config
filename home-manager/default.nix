{...}:
{
  imports = [
      <home-manager/nixos>
  ];

  home-manager.useGlobalPkgs = true;

  home-manager.users.piroks = { pkgs, config, ... }:
  let
    home = config.home.homeDirectory;
  in
  {
    imports = [
      ./xdg.nix
      ./mpd-instances.nix
      ./machine.nix
    ];

    xsession = {
      enable = true;
      numlock.enable = true;
      initExtra = with pkgs; ''
        ${xorg.xset}/bin/xset r rate 300 40
        $(${coreutils}/bin/sleep 1 && ${xorg.xsetroot}/bin/xsetroot -cursor_name left_ptr) &
      '';
    };

    programs.alacritty = {
      enable = true;
      settings = {

        window.opacity = 0.8;
        font.size = 17.0;

        colors.primary = {
          background = "#282828";
          foreground = "#ebdbb2";
        };

        colors.normal = {
          black   = "#282828";
          red     = "#cc241d";
          green   = "#98971a";
          yellow  = "#d79921";
          blue    = "#458588";
          magenta = "#b16286";
          cyan    = "#689d6a";
          white   = "#a89984";
        };

        colors.bright = {
          black   = "#928374";
          red     = "#fb4934";
          green   = "#b8bb26";
          yellow  = "#fabd2f";
          blue    = "#83a598";
          magenta = "#d3869b";
          cyan    = "#8ec07c";
          white   = "#ebdbb2";
        };
      };
    };

    services.dunst = {
      enable = true;
      settings = {
        global = {
          monitor = 0;
          follow = "mouse";
          width = 300;
          height = 300;
          origin = "top-right";
          offset = "10x50";
          scale = 0;
          notificaton_limit = 0;
          progress_bar = true;
          padding = 8;
          frame_color = "AAAAAA";
          separator_color = "frame";
          font = "Iosevka 14";
          markup = "full";
          alignment = "center";
          vertical_alignment = "center";
        };

        urgency_low = {
          background = "#282828";
          foreground = "#EBDBB2";
          timeout = 5;
        };

        urgency_normal = {
          background = "#282828";
          foreground = "#EBDBB2";
          timeout = 5;
        };

        urgency_critical = {
          background = "#282828";
          foreground = "#EBDBB2";
          frame_color = "#FF0000";
          timeout = 0;
        };
      };
    };

    programs.git = {
      enable = true;
      userName = "P1roks";
      userEmail = "piotrekjakobczyk1@gmail.com";
    };

    programs.gh = {
      enable = true;
    };

    programs.zathura = {
      enable = true;
      options = {
        guioptions = "";
        font = "iosevka normal 15";
        default-bg = "#282828";
        default-fg = "#EBDBB2";
        statusbar-fg = "#B0B0B0";
        statusbar-bg = "#202020";
        inputbar-bg = "#282828";
        inputbar-fg = "#A89984";
        notification-error-bg = "#CC241D";
        notification-error-fg = "#282828";
        notification-warning-bg = "#CC241D";
        notification-warning-fg = "#282828";
        highlight-color = "#F4BF75";
        highlight-active-color = "#458588";
        completion-highlight-fg = "#282828";
        completion-highlight-bg = "#90A959";
        completion-bg = "#928374";
        completion-fg = "#E0E0E0";
        notification-bg = "#90A959";
        notification-fg = "#282828";
        recolor = "true";
        recolor-lightcolor = "#282828";
        recolor-darkcolor = "#EBDBB2";
        recolor-reverse-video = "true";
        recolor-keephue = "true";
        render-loading = "false";
        scroll-step = 50;
        database = "sqlite";
      };
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
        nix-edit = "doas \$EDITOR /etc/nixos/configuration.nix +'cd %:h'";
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
}
