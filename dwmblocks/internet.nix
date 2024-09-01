{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      sb-internet = 
      let
        awk = "${pkgs.gawk}/bin/awk";
      in pkgs.writeShellScriptBin "sb-internet" ''
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

        [ "$(cat /sys/class/net/e*/operstate)" = "up" ] && echo "";

        curr_strength=$(${awk} 'NR == 3 {print substr($3,1,length($3)-1)}' /proc/net/wireless)
        if [ -z "$curr_strength" ]; then echo "󰤭";
        elif [ "$curr_strength" -ge 75 ]; then echo "󰤨";
        elif [ "$curr_strength" -ge 50 ]; then echo "󰤥"
        elif [ "$curr_strength" -ge 25 ]; then echo "󰤢"
        elif [ "$curr_strength" -ge 1 ]; then echo "󰤟"
        else echo "󰤭";
        fi;

      '';
    })
  ];

  environment.systemPackages = with pkgs; [ sb-internet ];
}
