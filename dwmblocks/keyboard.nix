{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      sb-kbd = 
      let
        awk = "${pkgs.gawk}/bin/awk";
        setxkbmap = "${pkgs.xorg.setxkbmap}/bin/setxkbmap";
        notify-send = "${pkgs.libnotify}/bin/notify-send";
        rofi = "${pkgs.rofi}/bin/rofi";
        buttons = import ./buttons.nix;
      in pkgs.writeShellScriptBin "sb-kbd" ''
        case $BLOCK_BUTTON in
          1)
            rules_location=$(${setxkbmap} -verbose 10 | grep "Trying to load rules file" | tail -n 1 | ${awk} '{print $NF}' | sed "s|\.\.\.|.lst|")
            language=$(${awk} 'BEGIN {display=0}
              $1=="!" {display = $2=="layout" ? 1 : 0; next}
              NF && display==1 {print $0}' "$rules_location" | ${rofi} -dmenu -i -p "language" | ${awk} '{print $1}')

            if test -z "$language"; then
              echo "language not selected! aborting!"
              exit 1
            fi

            variant=$(${awk} -v lang="$language:" 'BEGIN {display=0; print "default"}
              $1=="!" {display = $2=="variant" ? 1 : 0; next}
              NF && display==1 && $2==lang {$2 = ""; print $0}' "$rules_location" | ${rofi} -dmenu -i -p "variant" | ${awk} '{print $1}')

            if test -z "$variant" || test "$variant" == "default"; then
              ${setxkbmap} "$language"
            else
              ${setxkbmap} "$language" -variant "$variant"
            fi
          ;;
          ${buttons.rightMouseButton})
            ${notify-send} "" "$(${setxkbmap} -query)"
          ;;
        esac

        ${setxkbmap} -query | ${awk} '$1=="layout:" {printf "%s", toupper($2)} $1=="variant:" {printf " (%s)", $2} END {printf "\n"}'
      '';
    })
  ];

  environment.systemPackages = with pkgs; [ sb-kbd ];
}
