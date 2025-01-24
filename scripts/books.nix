{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      read_book =
        let
          booksPath = "$HOME/books/";
          lastBook = "${booksPath}.last";
        in
        pkgs.writeShellApplication {

        name = "read_book";
        runtimeInputs = with pkgs; [zathura rofi];

        excludeShellChecks = [ "SC2012"];
        bashOptions = ["errexit" "pipefail" "errtrace"];

        text = ''
          if [ "$1" == "last" ]; then
              zathura "${booksPath}$(cat "${lastBook}")"
              exit
          fi

          book=$(ls "${booksPath}" | rofi -i -dmenu)
          if test -z "$book"; then exit 0; fi
          echo "$book" > "${lastBook}"
          zathura "${booksPath}/$book"
        '';
      };
    })
  ];
}
