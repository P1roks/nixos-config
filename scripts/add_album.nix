{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      add_album = 
      let
        mpc = "${pkgs.mpc-cli}/bin/mpc";
        sed = "${pkgs.gnused}/bin/sed";
      in pkgs.writeShellScriptBin "add_album" ''
        set -eEo pipefail
        has_argument() {
          [[ ("$1" == *=* && -n ''${1#*=}) || ( -n "$2" && "$2" != -*)  ]];
        }

        extract_argument() {
          echo "''${2:-''${1#*=}}"
        }

        ext="mp3"

        handle_options() {
        while [ $# -gt 0 ]; do
          case $1 in
            # save as mpc playlist
            -s | --save*)
              if ! has_argument "$@"; then
                  echo "No save name provided!"; exit 1
              fi
              save_name=$(extract_argument "$@")
              test "$1" = "-s" && shift
              ;;

            # do not wipe previous mpc queue
            -k | --keep)
              keep=true
              ;;

            # mpc base directory, defaults to $XDG_MUSIC_DIR
            -m | --mpc-dir*)
              if ! has_argument "$@"; then
                  echo "No save name provided!"; exit 1
              fi
              mpc_directory=$(extract_argument "$@")
              if test ! -d "$mpc_directory"; then
                echo "provided directory is not a directory" & exit 1 
              fi
              test "$1" = "-m" && shift
              ;;

            -e | --extension*)
              if ! has_argument "$@"; then
                  echo "No extension provided!"; exit 1
              fi
              ext=$(extract_argument "$@")
              shift
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

        if ! test "$keep"; then
          ${mpc} clear -q
        fi

        if ! test "$mpc_directory"; then
          mpc_directory=''${XDG_MUSIC_DIR:-$HOME/Music}
        fi

        album_path=$(pwd | ${sed} -r "s|$mpc_directory/?||")

        mapfile -t files < <(ls -1v -- *."$ext")

        for file in "''${files[@]}";
        do
          ${mpc} add "$album_path/$file"
        done

        if test "$save_name"; then
         ${mpc} save "$save_name" 
        fi
      '';
    })
  ];
}
