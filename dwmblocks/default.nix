{pkgs, ...}:
{
  imports = [
    ./eye.nix
    ./time.nix
    ./music.nix
    ./disk.nix
    ./service.nix
  ];
}
