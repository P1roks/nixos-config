with import <nixpkgs> {};

let
  zathura = "${pkgs.zathura}/bin/zathura";
  rofi = "${pkgs.rofi}/bin/rofi";
  booksPath = "/home/piroks/books/";
  lastBook = "${booksPath}.last";
in writeShellScriptBin "read-book" ''
  if [ "$1" == "last" ]; then
      ${zathura} "${booksPath}$(cat ${lastBook})"
      exit
  fi

  book=$(ls ${booksPath} | ${rofi} -i -dmenu)
  echo "$book" > ${lastBook}
  ${zathura} "${booksPath}$book"
''
