{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      sb-battery = 
      let
        notify-send = "${pkgs.libnotify}/bin/notify-send";
        buttons = import ./buttons.nix;
      in pkgs.writeShellScriptBin "sb-battery" ''
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
          ${buttons.leftMouseButton})
            ${notify-send} "batteries" "$(get_capacities)"
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
    })
  ];

  environment.systemPackages = with pkgs; [ sb-battery ];
}
