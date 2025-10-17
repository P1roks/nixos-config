{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      sb-internet = pkgs.writeShellApplication {
        name = "sb-internet";

        bashOptions = ["errexit" "pipefail" "errtrace"];
        runtimeEnv = import ./buttons.nix;
        runtimeInputs = with pkgs; [ gawk  networkmanager];
        
        text = ''
          # choose_wifi(){
          #     wifi="$(nmcli device wifi list | tail -n +2 | cut -c 9- | awk '{printf "%s %s%%\n",$2,$7}' | dmenu -i | awk '{print $1}')";
          #     [ -z $wifi ] && exit
          #     password="$(dmenu -i -p Password)";
          #     nmcli device wifi connect "$wifi" password "$password;"
          # }
          #
          # case $BLOCK_BUTTON in
          #     1) choose_wifi;;
          # esac

          # I hate bash
          get_hotspot_status(){
            awk '$1 ~ /w.*/ && $2 == "00002A0A"' /proc/net/route
          }

          is_hotspot_on() {
            test ! -z "$(get_hotspot_status)"
          }

          is_ethernet_on() {
            test "$(cat /sys/class/net/e*/operstate)" = "up"
          }

          toggle_hotspot(){
            wifi_status="$(nmcli dev status | awk '$1 ~ /^w.*$/ {print $3}')"
            wifi_status="''${wifi_status:-}"
            if test "$wifi_status" != "connected"; then
              wifi_device="$(find /sys/class/net/w*)"
              wifi_device="''${wifi_device:-}"
              wifi_device="''${wifi_device##*/}"
              if test ! -z "$wifi_device"; then
                if "$(is_hotspot_on)"; then
                  nmcli con down Hotspot > /dev/null && notify-send "Hotspot: Off"
                else
                  nmcli dev wifi hotspot ifname "$wifi_device" ssid NixOS password functional > /dev/null && notify-send "Hotspot: On"
                fi
              fi
            fi
          }

          case $BLOCK_BUTTON in
            "$rightMouseButton")
              toggle_hotspot
            ;;
          esac

          if "$(is_hotspot_on)"; then
            echo "󱄙" && exit 0
          elif "$(is_ethernet_on)"; then
            echo "" && exit 0;
          fi

          curr_strength=$(awk 'NR == 3 {print substr($3,1,length($3)-1)}' /proc/net/wireless)
          if [ -z "$curr_strength" ]; then echo "󰤭";
          elif [ "$curr_strength" -ge 75 ]; then echo "󰤨";
          elif [ "$curr_strength" -ge 50 ]; then echo "󰤥"
          elif [ "$curr_strength" -ge 25 ]; then echo "󰤢"
          elif [ "$curr_strength" -ge 1 ]; then echo "󰤟"
          else echo "󰤭";
          fi;
        '';
      };
    })
  ];

  environment.systemPackages = with pkgs; [ sb-internet ];
}
