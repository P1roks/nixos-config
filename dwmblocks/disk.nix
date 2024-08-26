{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      sb-disk =
      let
        buttons = import ./buttons.nix;
        notify-send = "${pkgs.libnotify}/bin/notify-send";
      in pkgs.writeShellScriptBin "sb-disk" ''
        case "$BLOCK_BUTTON" in
          ${buttons.leftMouseButton})
            ${notify-send} "$(df -h / --output=size,used,avail,pcent)" ;;
        esac
      '';
    })
  ];

  environment.systemPackages = with pkgs; [ sb-disk ];
}
