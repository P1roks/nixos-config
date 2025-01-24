{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      sb-disk = pkgs.writeShellApplication {
        name = "sb-disk";

        bashOptions = ["errexit" "pipefail" "errtrace"];
        runtimeEnv = import ./buttons.nix;
        runtimeInputs = with pkgs; [ libnotify ];

        text =''
          case "$BLOCK_BUTTON" in
            "$leftMouseButton")
              notify-send "$(df -h / --output=size,used,avail,pcent)" ;;
          esac
        '';
      };
    })
  ];

  environment.systemPackages = with pkgs; [ sb-disk ];
}
