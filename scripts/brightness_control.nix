{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      brightness_control = pkgs.writeShellApplication {
        name = "brightness_control" ;

        bashOptions = ["errexit" "pipefail" "errtrace"];

        text = ''
          max="$(cat /sys/class/backlight/intel_backlight/max_brightness)";
        
          get_percentage() {
            current="$(cat /sys/class/backlight/intel_backlight/brightness)";
            echo "$(("$current" * 100 / "$max"))"
          }

          set_percentage() {
            echo "$(($1 * max / 100))" > /sys/class/backlight/intel_backlight/brightness
          }

          notify() {
            current=$(get_percentage)
            notify-send -r 42 -h "int:value:$current" "  Brightness [$current%]"
          }

          case "$1" in
            up)
              set_percentage $(($(get_percentage) + 5))
              notify
            ;;
            down)
              set_percentage $(($(get_percentage) - 5))
              notify
            ;;
            *)
              if [[ "$1" =~ ^[0-9]+$ ]] && ((0 <= "$1" <= 100)); then
                set_percentage "$1"
                notify
              else
                echo "Invalid argument passed! aborting!";
              fi
            ;;
          esac
        '';
      };
    })
  ];
}
