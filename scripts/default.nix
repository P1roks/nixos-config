{ ... }:
{
  imports = [
    ./books.nix
    ./add_album.nix
    ./tag_album.nix
    ./screenshot.nix
    ./volume_control.nix
    ./brightness_control.nix
    ./blood_picker.nix
    ./spawn_session_shell.nix
  ];
}
