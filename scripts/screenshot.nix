{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      pshot = pkgs.writeShellApplication {
        name = "pshot";

        bashOptions = ["errexit" "pipefail" "errtrace"];
        runtimeInputs = with pkgs; [scrot libnotify xclip];

        text = ''
          select=false
          focused_monitor=true
          scrot_args=()
          out_dir=""

          has_argument() {
            [[ ("$1" == *=* && -n ''${1#*=}) || ( -n "$2" && "$2" != -*)  ]];
          }

          extract_argument() {
            echo "''${2:-''${1#*=}}"
          }

          handle_options() {
            while [ $# -gt 0 ]; do
              case $1 in
                -f | --file*)
                  if ! has_argument "$@"; then
                    echo "file not specified"
                    exit 1
                  fi
                  out_dir=$(extract_argument "$@")
                  out_dir=''${out_dir%/}
                  test "$1" = "-f" && shift
                  ;;

                -s | --select)
                  select=true
                  ;;

                -a | --all-monitors)
                  focused_monitor=false
                  ;;

                *)
                  echo "Invalid option '$1' specified! Aborting"
                  exit 1
                  ;;
              esac
              shift
            done
          }

          handle_options "$@"

          if [ "$select" == true ]; then
            scrot_args+=("-s")    
          fi

          if [ "$focused_monitor" == true ] && [ "$select" == false ]; then
              scrot_args+=("-u")
          fi

          if [ -z "$out_dir"  ]; then
            scrot_args+=("-f" '/tmp/%F_%T.png')
            scrot_args+=("-e" "xclip -selection clipboard -t image/png -i \$f")
          else
            scrot_args+=("-f" "''${out_dir}/%F_%T.png")
          fi

          scrot "''${scrot_args[@]}" && notify-send "pshot" "screenshot has been taken!"
        '';
      };
    })
  ];
}
