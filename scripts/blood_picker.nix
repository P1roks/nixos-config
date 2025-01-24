{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      blood_picker = pkgs.writeShellApplication {
        name = "blood_picker";

        runtimeInputs = [ pkgs.nblood pkgs.rofi ];

        text = ''
          nblood_dir="/var/lib/games/nblood"

          declare -A launch_options

          while read -r line; do
              [[ $line = *=* ]] && launch_options[''${line%%=*}]=''${line#*=}
          done < "$nblood_dir/launch_options.txt"

          autoload=()

          while IFS= read -r -d $'\0'; do
              autoload+=("-grp" "autoload/$REPLY")
          done < <(find "$nblood_dir/autoload" -type f -printf "%f\0")

          selected=$(printf "%s\n" "''${!launch_options[@]}" | sort | rofi -i -dmenu -sort "true")

          declare -a flags
          IFS=" " read -r -a flags <<< "''${launch_options[$selected]}"
          flags+=("''${autoload[@]}")

          nblood "''${flags[@]}"
        '';
      };
    })
  ];
}
