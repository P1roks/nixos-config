{ pkgs, ... }:
{
  systemd.user.services = {
    copyq =
    let
      copyq = "${pkgs.copyq}/bin/copyq";
    in {
      enable = true;

      name = "copyq";
      description = "copyq clipboard history";

      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];

      serviceConfig = {
        ExecStart = copyq;
        Restart = "always";
        RestartSec = 3;
      };
    };

    dwmblocks =
    let
      dwmblocks = "${pkgs.dwmblocks}/bin/dwmblocks";
    in {
      enable = true;

      name = "dwmblocks";
      description = "interactive status bar for dwm";

      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      path = [ "/run/current-system/sw" ];

      serviceConfig = {
        ExecStart = dwmblocks;
        Restart = "always";
        RestartSec = 3;
      };
    };

    mpdIdle =
    let
      mpc = "${pkgs.mpc-cli}/bin/mpc";
      pkill = "${pkgs.procps}/bin/pkill";
    in {
      enable = true;

      name = "mpd-idle";
      description = "";

      wantedBy = [ "default.target" ];
      after = [ "mpd.service" ]; 

      script = ''
        while :; do
          ${mpc} idle
          ${pkill} -RTMIN+11 dwmblocks
        done
      '';
    };

    redshift =
    let
      redshift = "${pkgs.redshift}/bin/redshift";
    in {
      name = "redshift";
      description = "one-shot, simple way to trigger night mode";

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${redshift} -O 4500K";
        ExecStop = "${redshift} -x";
      };
    };

  };
}
