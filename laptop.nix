{ pkgs, ... }:
{
  boot.initrd.luks.devices = {
    crypted = {
      device = "/dev/disk/by-uuid/49cf9b75-caf0-459a-8b5b-06fa22ae1a41";
      preLVM = true;
    };
  };

  services.udev.extraRules = ''
    RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/intel_backlight/brightness"
    RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/intel_backlight/brightness"
  '';

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };

  services.xscreensaver.enable = true;
  security.pam.services.xscreensaver.enable = true;
  environment.systemPackages = with pkgs; [ xscreensaver ];

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
        command = "sb-battery";
        interval = 60;
        signal = 3;
      }
      {
        command = "sb-internet";
        interval = 20;
        signal = 4;
      }
      {
        icon = " ";
        command = "sb-disk";
        signal = 13;
      }
    ];
  };
}
