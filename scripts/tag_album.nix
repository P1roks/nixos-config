{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      tag_album = pkgs.writeShellApplication {
        name = "tag_album";

        runtimeInputs = with pkgs; [findutils gnused python312Packages.mutagen];
        bashOptions = ["errexit" "pipefail" "errtrace"];

        text = ''
          has_argument() {
              [[ ("$1" == *=* && -n ''${1#*=}) || ( -n "$2" && "$2" != -*)  ]];
          }

          extract_argument() {
            echo "''${2:-''${1#*=}}"
          }

          trim_whitespace() {
            echo "$1" | xargs
          }

          separator="\-"
          number_separator="\."
          ext="mp3"

          handle_options() {
            while [ $# -gt 0 ]; do
              case $1 in
                # for albumns in <number>.<name>.mp3 format
                -a | --artist*)
                  if ! has_argument "$@"; then
                      echo "No artist provided!"; exit 1
                  fi
                  artistless=true
                  artist=$(extract_argument "$@")
                  test "$1" = "-a" && shift
                  ;;
                
                # specify music file extension
                -e | --extension*)
                  if ! has_argument "$@"; then
                      echo "No extension provided!"; exit 1
                  fi
                  ext=$(extract_argument "$@")
                  test "$1" = "-e" && shift
                  ;;

                # specify separator between song and artist
                -s | --separator*)
                  if ! has_argument "$@"; then
                      echo "No separator provided!"; exit 1
                  fi
                  separator=$(extract_argument "$@")
                  test "$1" = "-s" && shift
                  ;;

                # specify separator between song number and rest of filename
                -n | --number-separator*)
                  if ! has_argument "$@"; then
                      echo "No number separator provided!"; exit 1
                  fi
                  number_separator=$(extract_argument "$@")
                  test "$1" = "-n" && shift
                  ;;

                # specify working dir
                -d | --directory*)
                  if ! has_argument "$@"; then
                      echo "No directory provided!"; exit 1
                  fi
                  directory=$(extract_argument "$@")
                  if test ! -d "$directory"; then
                    echo "provided directory is not a directory" & exit 1 
                  fi
                  test "$1" = "-d" && shift
                  ;;

                # specify album, if not specified album is assumed to be directory name
                -A | --album*)
                  if ! has_argument "$@"; then
                      echo "No album name provided!"; exit 1
                  fi
                  album_name=$(extract_argument "$@")
                  test "$1" = "-A" && shift
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

          if test -n "$directory"; then
            pushd "$directory" || echo "Cannot change to dir! Aborting" && exit
          fi

          if test ! -n "$album_name"; then
            album_name=''${PWD##*/}
          fi

          if test "$artistless"; then
            sed_pattern="s|^([0-9][0-9]?)$number_separator(.*)\.$ext|\1\n\2|"
          else
            sed_pattern="s|^([0-9][0-9]?)$number_separator(.*)$separator(.*)\.$ext|\1\n\2\n\3|"
          fi

          mapfile -t files < <(ls -1v -- *."$ext")
          total=''${#files[@]}

          if test "$total" = "0"; then
            echo "Provided directory doesn't contain any files!" && exit 1
          fi

          for file in "''${files[@]}";
          do
            mapfile -t songinfo < <(echo "$file" | sed -r "$sed_pattern")
            track_number="$((10#''${songinfo[0]}))"
            track_number="$track_number/$total"
            
            if test "$artistless"; then
              song_name=$(trim_whitespace "''${songinfo[1]}")
            else
              artist=''${songinfo[1]}
              song_name=$(trim_whitespace "''${songinfo[2]}")
            fi
            
            echo "
          tagging file '$file' with:
          album name: $album_name
          artist: $artist
          number: $track_number
          song: $song_name
            "

            mid3v2 --artist="$artist" --album="$album_name" --song="$song_name" --track="$track_number" "$file"
          done

          if test -n "$directory"; then
            popd || exit 1
          fi
        '';
      };
    })
  ];
}

