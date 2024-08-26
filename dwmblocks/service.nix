{ config, lib, pkgs, ... }:
with lib;
let
  name = "dwmblocks";

  cfg = config.services.dwmblocks;

  blockConfigType = types.submodule {
    options = {

      icon = mkOption {
        type = types.str;
        default = "";
        description = ''
          Static text to be displayed by this block 
        '';
        example = "Mem: ";
      };

      command = mkOption {
        type = types.str;
        default = "";
        description = ''
          The command to be run by this block upon update
        '';
        example = "free -h | awk '/^Mem/ { print $3\"/\"$2 }' | sed s/i//g";
      };

      interval = mkOption {
        type = types.int;
        default = 0;
        description = ''
          Interval in which the block updates. When set to 0 the block never updates
        '';
        example = 30;
      };

      signal = mkOption {
        type = types.int;
        default = 0;
        description = ''
          The signal that, when transmitted to dwmblocks, makes it restart this block
        '';
        example = 12;
      };

    };
  };

  blocks =
  if lib.isString cfg.blocks then cfg.blocks
  else concatMapStrings (block: block + ",")
    (map (block: ''{"${block.icon}", "${block.command}", ${toString block.interval}, ${toString block.signal}}'') cfg.blocks);
  dwmblocks = cfg.package.override {
    patches = cfg.patches;
    conf = ''
      static const Block blocks[] = {
        ${blocks}
      };

      static char delim[] = "${cfg.delimiter}";
      static unsigned int delimLen = ${toString cfg.delimiterLength};

      ${cfg.extraConfig}
    '';
  };

in {
  ### Options

  options.services.dwmblocks = {

    enable = mkEnableOption "dwmblocks";     

    package = mkPackageOption pkgs "dwmblocks" { };

    patches = mkOption {
      type = types.listOf types.path;
      default = [ ];
      description = ''
        The path to the patches to be applied, if any
      '';
      example = ''
        [
          # local patch
          ./path/to/local/patch

          # external patch
          (pkgs.fetchpatch {
            url = "example.com";
            hash = "";
          })
        ]
      '';
    };

    delimiter = mkOption {
      type = types.str;
      default = " | ";
      description = ''
        Delimiter used to separate specific blocks
      '';
      example = " ; ";
    }; 

    delimiterLength = mkOption {
      type = types.int;
      default = 5;
      description = ''
        Length of the delimiter
      '';
      example = 10;
    };

    blocks = mkOption {
      type = types.either types.lines (types.listOf blockConfigType);
      default = [ ];
      description = ''
        Block configuration represented as list of sets describing a block or lines of raw C code
      '';
      example = ''
      # as sets
      [
        {
          icon = "Mem: ";
          command = "free -h | awk '/^Mem/ { print $3\"/\"$2 }' | sed s/i//g";
          interval = 30;
          signal = 0;
        }
        {
          command = "date '+%b %d (%a) %I:%M%p'";
          interval = 5;
        }
      ]

      # raw C code
      "
        {"Mem:", "free -h | awk '/^Mem/ { print $3\"/\"$2 }' | sed s/i//g",	30,		0},
        {"", "date '+%b %d (%a) %I:%M%p'",					5,		0},
      "

      '';
    };

    extraConfig = mkOption {
      type = types.str;
      default = "";
      description = ''
        Any extra raw C code to be injected at the end of blocks.def.h
      '';
      example = ''
        int somePatchedVariable = 10;
      '';
    };
    
  };

  ### Implementation

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = config.services.xserver.windowManager.dwm.enable;
        message = "dwm must be enabled for dwmblocks to work";
      }
    ]; 

    systemd.user.services.dwmblocks = {
      enable = true;

      description = "interactive status bar for dwm";

      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      path = [ "/run/current-system/sw" ];

      serviceConfig = {
        ExecStart = "${dwmblocks}/bin/dwmblocks";
        Restart = "always";
        RestartSec = 3;
      };
    };

    environment.systemPackages = [ dwmblocks ];
  }; 
}
