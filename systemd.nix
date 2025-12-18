{ pkgs, ... }:
{
  systemd.user.services.copyqq = 
  let
      copyq = "${pkgs.copyq}/bin/copyq";
  in 
  {
    enable = true;

    description = "copyq clipboard history";

    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];

    serviceConfig = {
      ExecStart = copyq;
      Restart = "always";
      RestartSec = 3;
    };
  };

  systemd.user.services.mpdIdle = 
  let
    mpc = "${pkgs.mpc}/bin/mpc";
    pkill = "${pkgs.procps}/bin/pkill";
  in
  {
    enable = true;

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

}
