{ pkgs, ... }:
{
  environment.systemPackages = 
  let
    mpc = "${pkgs.mpc-cli}/bin/mpc";
    rofi = "${pkgs.rofi}/bin/rofi";
    sb-music = 
      with (import ./buttons.nix);
      pkgs.writeShellScriptBin "sb-music" ''
        filter() { ${mpc} -f "%title%" | sed "/^volume:/d;s/\\&/&/g;s/\\[paused\\].*//g;/\\[playing\\].*/d;/^ERROR/Q" | paste -sd ' ' -;}
        choseplaylist() {
          choice="$(${mpc} lsplaylist | sort | ${rofi}/bin/rofi -dmenu -i )";
          if test -n "$choice"
          then
            ${mpc} clear && ${mpc} load "$choice" && ${mpc} play;
          fi
        }

        pidof -x sb-mpdup >/dev/null 2>&1 || sb-mpdup >/dev/null 2>&1 &

        case "$BLOCK_BUTTON" in
          ${leftMouseButton}) ${mpc} toggle | filter ;;
          ${rightMouseButton}) ${mpc} status | filter; notify-send "playlist" "$(${mpc} playlist | tail -n +$(${mpc} -f "%position%" | head -n 1) | sed -r "1s|(.*)|<span color=\"red\">\1</span>|")";;
          ${scrollClick}) ${mpc} -p 6601 status | awk 'NR==1 {split($0,a,"/"); print a[2]} NR==2 {print $3}' | xargs -d '\n' notify-send ;;  # right click, show currently playing podcast
          ${scrollUp}) ${mpc} prev | filter ;;  # scroll up, previous
          ${scrollDown}) ${mpc} next | filter ;;  # scroll down, next
          ${leftMouseButtonControl}) ${mpc} stop ;; # ctrl + left click - stop displaying song title
          ${rightMouseButtonControl}) choseplaylist ;; # 
          ${scrollUpControl}) ${mpc} volume +10 ;;
          ${scrollDownControl}) ${mpc} volume -10 ;;
          *) ${mpc} status | filter ;;
        esac
      '';
  in [ sb-music ];
}
