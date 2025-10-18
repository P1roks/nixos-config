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

          mode_path=(/sys/bus/platform/drivers/ideapad_acpi/*/conservation_mode)
          curr_mode=""
          if test -f "''${mode_path[@]}"; then
            curr_mode=$(cat "''${mode_path[@]}")
          fi

          case $BLOCK_BUTTON in 
            "$leftMouseButton")
              notify-send "batteries" "$(get_capacities)"
            ;;
            "$rightMouseButton")
              if test ! -z "''${curr_mode}"; then
                curr_mode="$((1 - curr_mode))"
                echo "$curr_mode" > "''${mode_path[@]}"
                if test "$curr_mode" = "1"; then
                  notify-send "Conservation Mode:ON"
                else
                  notify-send "Conservation Mode:OFF"
                fi
                pkill -RTMIN+3 dwmblocks
              fi
            ;;
          esac

          if test ! -z "''${curr_mode}" && test "$curr_mode" = "1"; then printf "󰌪"; fi

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
