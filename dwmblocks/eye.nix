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
      sb-eye = pkgs.writeShellApplication {
        name = "sb-eye";

        bashOptions = ["errexit" "pipefail" "errtrace"];
        runtimeEnv = import ./buttons.nix;

        text = ''
          if [ "$BLOCK_BUTTON" == $leftMouseButton ]; then
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
      };
    }) 
  ];

  environment.systemPackages = with pkgs; [ sb-eye ];
}
