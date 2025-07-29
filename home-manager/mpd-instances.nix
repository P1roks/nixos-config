{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.mpdInstances;

  configs = listToAttrs
    (map (i: {
    name = i.serviceName;
    value = {
      conf = 
        pkgs.writeText "mpd.conf" ''
        music_directory     "${i.musicDirectory}"
        playlist_directory  "${i.playlistDirectory}"
        ${lib.optionalString (i.dbFile != null) ''
          db_file             "${i.dbFile}"
        ''}
        state_file          "${i.dataDir}/state_${i.serviceName}"
        sticker_file        "${i.dataDir}/sticker_${i.serviceName}.sql"

        ${optionalString (i.network.listenAddress != "any")
        ''bind_to_address "${i.network.listenAddress}"''}
        ${optionalString (i.network.port != 6600)
        ''port "${toString i.network.port}"''}

        ${i.extraConfig}
      '';
    };
  }) cfg.instances);

  services = listToAttrs
    (map (i: {
      name = i.serviceName;
      value = {
        Unit = {
          After = [ "network.target" "sound.target" ];
          Description = "Music Player Daemon";
        };

        Install = mkIf (!i.network.startWhenNeeded) {
          WantedBy = [ "default.target" ];
        };

        Service = {
          Environment = "PATH=${config.home.profileDirectory}/bin";
          ExecStart = "${cfg.package}/bin/mpd --no-daemon ${configs.${i.serviceName}.conf} ${
              escapeShellArgs i.extraArgs
            }";
          Type = "notify";
          ExecStartPre = ''
            ${pkgs.bash}/bin/bash -c "${pkgs.coreutils}/bin/mkdir -p '${i.dataDir}' '${i.playlistDirectory}'"'';
        };
      };
    }) cfg.instances);

  sockets = listToAttrs
    (map (i: {
      name = i.serviceName;
      value = {
        Socket = {
          ListenStream = let
            listen = if i.network.listenAddress == "any" then
              toString i.network.port
            else
              "${i.network.listenAddress}:${toString i.network.port}";
          in [ listen "%t/mpd/socket" ];
      
          Backlog = 5;
          KeepAlive = true;
        };
      
        Install = { WantedBy = [ "sockets.target" ]; };
      };
    }) (filter (i: i.network.startWhenNeeded) cfg.instances));

  mpdInstanceOptions = types.submodule ({ config, ... }: {
    options = {
      
      serviceName = mkOption {
        type = types.str;
        default = "mpd";
        description = ''
          Name of instance's systemd service
        '';
      };

      musicDirectory = mkOption {
        type = with types; either path str;
        default = if lib.hasAttrByPath ["xdg" "userDirs" "enable"] config && config.xdg.userDirs.enable
          then config.xdg.userDirs.music 
          else "${config.home.homeDirectory}/music";
        apply = toString; # Prevent copies to Nix store.
        description = ''
          The directory where mpd reads music from.

          If [](#opt-xdg.userDirs.enable) is
          `true` then the defined XDG music directory is used.
          Otherwise, you must explicitly specify a value.
        '';
      };

      playlistDirectory = mkOption {
        type = types.path;
        default = "${config.dataDir}/playlists_${config.serviceName}";
        apply = toString; # Prevent copies to Nix store.
        description = ''
          The directory where mpd stores playlists.
        '';
      };

      extraConfig = mkOption {
        type = types.lines;
        default = "";
        description = ''
          Extra directives added to to the end of MPD's configuration
          file, {file}`mpd.conf`. Basic configuration
          like file location and uid/gid is added automatically to the
          beginning of the file. For available options see
          {manpage}`mpd.conf(5)`.
        '';
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = [ "--verbose" ];
        description = ''
          Extra command-line arguments to pass to MPD.
        '';
      };

      dataDir = mkOption {
        type = types.path;
        default = "${config.xdg.dataHome}/mpd";
        apply = toString; # Prevent copies to Nix store.
        description = ''
          The directory where MPD stores its state, tag cache,
          playlists etc.
        '';
      };

      network = {
        startWhenNeeded = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Enable systemd socket activation.
          '';
        };

        listenAddress = mkOption {
          type = types.str;
          default = "127.0.0.1";
          example = "any";
          description = ''
            The address for the daemon to listen on.
            Use `any` to listen on all addresses.
          '';
        };

        port = mkOption {
          type = types.port;
          default = 6600;
          description = ''
            The TCP port on which the the daemon will listen.
          '';
        };

      };

      dbFile = mkOption {
        type = types.nullOr types.str;
        default = "${config.dataDir}/tag_cache_${config.serviceName}";
        description = ''
          The path to MPD's database. If set to
          `null` the parameter is omitted from the
          configuration.
        '';
      };
    };
  });

in {

  ###### interface

  options.services.mpdInstances = {

    enable = mkEnableOption "mpd";

    package = mkPackageOption pkgs "mpd" { };

    instances = mkOption {
      type = types.listOf mpdInstanceOptions;
      default = [ ];
      description = "Definitions of all mpd instances";
    };
  };

  ###### implementation

  config = mkIf cfg.enable {
    assertions = [
      (lib.hm.assertions.assertPlatform "services.mpdInstances" pkgs lib.platforms.linux)
    ];

    systemd.user.services = services;
    systemd.user.sockets = sockets;

    home.packages = [ cfg.package ];
  };

}
