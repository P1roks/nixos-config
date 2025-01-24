{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      sb-time = pkgs.writeShellApplication {
        name = "sb-time";

        bashOptions = ["errexit" "pipefail" "errtrace"];
        runtimeEnv = import ./buttons.nix;
        runtimeInputs = with pkgs; [ libnotify ];

        text = ''
          case $BLOCK_BUTTON in
            "$leftMouseButton")
              notify-send " " "$(cal --color=always | sed 's|.\[7m|<b><span color=\"red\">|;s|.\[0m|</span></b>|')" ;;
          esac

          echo  "$(date "+%H:%M")" 
        '';
      };
    })
  ];

  environment.systemPackages = with pkgs; [ sb-time ];
}
