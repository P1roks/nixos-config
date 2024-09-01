{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      volume_control =
      let
        notify-send = "${pkgs.libnotify}/bin/notify-send";
        pulsemixer = "${pkgs.pulsemixer}/bin/pulsemixer";
        amixer = "${pkgs.alsa-utils}/bin/amixer";
      in
      pkgs.writeShellScriptBin "volume_control" ''
        notify() {
          volume=$(${pulsemixer} --get-volume | awk '{print $1}')
          normalized_volume=$((volume * 100 / 153))
          ${notify-send} -r 43 -h "int:value:$normalized_volume" "󰕾 Volume level [$volume]"
        }

        case "$1" in
          up)
            ${pulsemixer} --change-volume +5
            notify
          ;;
          down)
            ${pulsemixer} --change-volume -5
            notify
          ;;
          toggle-sound)
            ${pulsemixer} --toggle-mute
          ;;
          toggle-microphone)
            ${amixer} set Capture toggle
          ;;
        esac
      '';
    })
  ];
}
