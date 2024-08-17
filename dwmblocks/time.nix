{ pkgs, ... }:
{
  environment.systemPackages = 
  let
    buttons = import ./buttons.nix;
    notify-send = "${pkgs.libnotify}/bin/notify-send";
    sb-time = pkgs.writeShellScriptBin "sb-time" ''
    case $BLOCK_BUTTON in
      ${buttons.leftMouseButton})
        ${notify-send} " " "$(cal --color=always | sed 's|.\[7m|<b><span color=\"red\">|;s|.\[0m|</span></b>|')" ;;
    esac

    echo  $(date "+%H:%M") 
  '';
  in [ sb-time ];
}
