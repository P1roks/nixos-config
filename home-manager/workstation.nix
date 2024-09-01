{config, ...}:
let
  home = config.home.homeDirectory;
in
{
    services.mpdInstances =
    {
      enable = true;

      instances = [
        {
          serviceName = "mpd";
          dataDir = "${home}/.config/mpd";
          musicDirectory = config.xdg.userDirs.music;
          extraConfig = ''
            audio_output {
              type "pulse"
              name "Sound server"
            }
          '';
        }
        {
          serviceName = "mpd-cast";
          dataDir = "${home}/.config/mpd";
          musicDirectory = config.xdg.userDirs.music;
          dbFile = null;
          network.port = 6601;
          extraConfig = ''
            audio_output {
              type "pulse"
              name "Sound server"
            }
          '';
        }
      ];
    };
}
