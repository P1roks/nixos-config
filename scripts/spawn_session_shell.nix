{pkgs, ...}:
{
  nixpkgs.overlays = [
    (final: prev: {
      spawn_session_shell = pkgs.writeShellApplication {

        name = "spawn_session_shell";

        runtimeInputs = with pkgs; [ xdotool procps ];

        text = ''
          windowid=$(xdotool getwindowfocus getwindowpid)
          shellpid=$(ps -o pid= --ppid "$windowid" | tr -d " \t\n\r")
          shells=$(ps -o pid,comm -g "$shellpid")

          deepest_shell=$(
              awk -v CURRENT_SHELL="$$" \
                '$1 != CURRENT_SHELL && $2 ~ /fish|bash|ksh|zsh|nu|sh|dash/ {SHELL=$0} END {print SHELL}' <<< "$shells"
          )
          deepest_shell=''${deepest_shell:-}
          deepest_shell_pid=$(awk '{print $1}' <<< "$deepest_shell")
          deepest_shell_name=$(awk '{print $2}' <<< "$deepest_shell")

          { test -z "''${deepest_shell_pid:-}" || test ! -r "/proc/$deepest_shell_pid/environ"; } && exit 1

          workdir=$(readlink -f "/proc/$deepest_shell_pid/cwd" 2> /dev/null || echo "$HOME")

          envpairs=()
          while IFS= read -r -d ''' kv; do
            test -z "''${kv}" && continue
            case "$kv" in
              OLDPWD=*|SHLVL=*|_=*) continue ;;
            esac
            envpairs+=("$kv")
          done < "/proc/$deepest_shell_pid/environ"

          test ''${#envpairs[@]} -eq 0 && exit 1

          exec env -i "''${envpairs[@]}" "$TERMINAL" --working-directory "$workdir" -e "$deepest_shell_name" &
        '';
      };
    })
  ];
}
