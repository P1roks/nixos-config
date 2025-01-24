{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      sb-battery = pkgs.writeShellApplication {
        name = "sb-battery";

        bashOptions = ["errexit" "pipefail" "errtrace"];
        runtimeEnv = import ./buttons.nix;
        runtimeInputs = with pkgs; [ libnotify ];

        text = ''
          get_capacities(){
            msg="";
            for battery in /sys/class/power_supply/BAT?*; do
              bat_name=''${battery##*/};
              bat_level=$(cat "$battery/capacity");
              msg="$msg$bat_name: $bat_level%<br>"
            done;
            echo "$msg";
          }

          case $BLOCK_BUTTON in 
            "$leftMouseButton")
              notify-send "batteries" "$(get_capacities)"
            ;;
          esac

          for battery in /sys/class/power_supply/BAT?*; do
            bat_status=$(cat "$battery/status");
            bat_level="$(cat "$battery/capacity" 2>&1)";
            [ -n "''${bat_level+x}" ] && printf " ";

            case "$bat_status" in
              "Charging") status="" ;;
            esac

            if [ -z "$status" ]; then
              if   [ "$bat_level" -ge 75 ]; then status="";
              elif [ "$bat_level" -ge 50 ]; then status="";
              elif [ "$bat_level" -ge 25 ]; then status="";
              elif [ "$bat_level" -ge 1 ]; then status="";
              else status="";
              fi;
            fi
            printf "%s %s%%" "$status" "$bat_level";
            unset status
          done;
        '';

      };
    })
  ];

  environment.systemPackages = with pkgs; [ sb-battery ];
}
