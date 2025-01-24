{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      volume_control = pkgs.writeShellApplication {
        name = "volume_control";

        bashOptions = ["errexit" "pipefail" "errtrace"];
        runtimeInputs = with pkgs; [libnotify pulsemixer alsa-utils];

        text = ''
        notify() {
          volume=$(pulsemixer --get-volume | awk '{print $1}')
          normalized_volume=$((volume * 100 / 153))
          notify-send -r 43 -h "int:value:$normalized_volume" "󰕾 Volume level [$volume]"
        }

        case "$1" in
          up)
            pulsemixer --change-volume +5
            notify
          ;;
          down)
            pulsemixer --change-volume -5
            notify
          ;;
          toggle-sound)
            pulsemixer --toggle-mute
          ;;
          toggle-microphone)
            amixer set Capture toggle
          ;;
        esac
        '';
      };
    })
  ];
}
