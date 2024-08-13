with import <nixpkgs> {};
with import ./buttons.nix;

writeShellScriptBin "sb-time" ''
  case $BLOCK_BUTTON in
    ${leftMouseButton})
      notify-send " " "$(cal --color=always | sed 's|.\[7m|<b><span color=\"red\">|;s|.\[0m|</span></b>|')" ;;
  esac

  echo  $(date "+%H:%M") 
''
