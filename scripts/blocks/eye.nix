with import ./buttons.nix; 
with import <nixpkgs> {};

writeShellScriptBin "sb-eye" ''
  if [ "$BLOCK_BUTTON" == ${leftMouseButton} ]; then
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
''
