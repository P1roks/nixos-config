{ pkgs, ... }:
{
  systemd.user.services.redshift = 
  let
    redshift = "${pkgs.redshift}/bin/redshift";
  in
  {
    description = "one-shot, simple way to trigger night mode";

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${redshift} -O 4500K";
      ExecStop = "${redshift} -x";
    };
  };

  nixpkgs.overlays = [
   (final: prev: {
    sb-eye =
    let buttons = import ./buttons.nix;
    in pkgs.writeShellScriptBin "sb-eye" ''
      if [ "$BLOCK_BUTTON" == ${buttons.leftMouseButton} ]; then
          case $(systemctl --user is-active redshift) in
              active)
                  systemctl --user stop --now redshift ;;
              inactive)
                  systemctl --user start --now redshift ;;
          esac
          pkill -RTMIN+12 dwmblocks
      fi

      case $(systemctl --user is-active redshift) in
          active)
              echo "" ;;
          inactive)
              echo "" ;;
      esac
    '';
   }) 
  ];

  environment.systemPackages = with pkgs; [ sb-eye ];
}
