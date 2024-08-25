{ pkgs, ... }:
{
  environment.systemPackages = 
  let 
    buttons = import ./buttons.nix;
    notify-send = "${pkgs.libnotify}/bin/notify-send";
    sb-disk = pkgs.writeShellScriptBin "sb-disk" ''
      case "$BLOCK_BUTTON" in
        ${buttons.leftMouseButton})
          ${notify-send} "$(df -h / --output=size,used,avail,pcent)" ;;
      esac
    '';
  in [ sb-disk ];
}
