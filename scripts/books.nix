{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      read_book =
      let
        zathura = "${pkgs.zathura}/bin/zathura";
        rofi = "${pkgs.rofi}/bin/rofi";
        booksPath = "$HOME/books/";
        lastBook = "${booksPath}.last";
      in pkgs.writeShellScriptBin "read_book" ''
        if [ "$1" == "last" ]; then
            ${zathura} "${booksPath}$(cat ${lastBook})"
            exit
        fi

        book=$(ls ${booksPath} | ${rofi} -i -dmenu)
        if test -z "$book"; then exit 0; fi
        echo "$book" > ${lastBook}
        ${zathura} "${booksPath}$book"
      '';
    })
  ];
}
