{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      sb-time =
      let
        buttons = import ./buttons.nix;
        notify-send = "${pkgs.libnotify}/bin/notify-send";
      in pkgs.writeShellScriptBin "sb-time" ''
        case $BLOCK_BUTTON in
          ${buttons.leftMouseButton})
            ${notify-send} " " "$(cal --color=always | sed 's|.\[7m|<b><span color=\"red\">|;s|.\[0m|</span></b>|')" ;;
        esac

        echo  $(date "+%H:%M") 
      '';
    })
  ];

  environment.systemPackages = with pkgs; [ sb-time ];
}
