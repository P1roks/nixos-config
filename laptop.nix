{ pkgs, ... }:
{
  boot.initrd.luks.devices = {
    crypted = {
      device = "/dev/disk/by-uuid/49cf9b75-caf0-459a-8b5b-06fa22ae1a41";
      preLVM = true;
    };
  };

  services.dwmblocks = {
    blocks = [
      {
        command = "sb-music";
        signal = 11;
      }
      {
        command = "sb-eye";
        signal = 12;
      }
      {
        command = "sb-time";
        interval = 60;
        signal = 1;
      }
      {
        icon = " ";
        command = "sb-disk";
        signal = 13;
      }
    ];
  };
}
