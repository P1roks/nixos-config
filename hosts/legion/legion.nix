{ config, pkgs, ... }:
{
  boot.initrd = {
    kernelModules = [ "i915" ];
    luks = {
      devices = {
        crypted = {
          device = "/dev/disk/by-uuid/96de9cd5-2227-4372-bbd8-124969e521fd";
          preLVM = true;
        };
      };
    };
  };

  boot.extraModulePackages = with config.boot.kernelPackages; [
    lenovo-legion-module
    nvidia_x11
  ];

  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    nvidiaSettings = true;
    powerManagement = {
      enable = true;
      finegrained = true;
    };
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # boot.kernelParams = [
  #   "ibt=off"
  # ];

  services.xserver.videoDrivers = [ "nvidia" ];

  services.udev.extraRules =
  let disableNvidia = ''
    # Remove NVIDIA USB xHCI Host Controller devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{power/control}="auto", ATTR{remove}="1"

    # Remove NVIDIA USB Type-C UCSI devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{power/control}="auto", ATTR{remove}="1"

    # Remove NVIDIA Audio devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"

    # Remove NVIDIA VGA/3D controller devices
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto", ATTR{remove}="1"
  ''; in ''
    # allow modification of brightness levels
    RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/intel_backlight/brightness"
    RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/intel_backlight/brightness"

    # allow the toggle of conservation mode
    RUN+="${pkgs.coreutils}/bin/chgrp video /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode"
    RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode"
  ''; # + disableNvidia;


  powerManagement.powertop.enable = true;
  services = {
    power-profiles-daemon.enable = false;
    tlp = {
      enable = true;
        settings = {
        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 0;
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        STOP_CHARGE_THRESH_BAT0 = 95;
      };
    };
  };

  services.xscreensaver.enable = true;
  security.pam.services.xscreensaver.enable = true;

  environment.systemPackages = with pkgs; [ xscreensaver powertop ];

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

  # allow hotspot to function
  networking = {
    networkmanager.dns = "dnsmasq";
    firewall = {
      checkReversePath = "loose";
      allowedUDPPorts = [ 67 68 53 ];
      allowedTCPPorts = [ 53 ];
    };
  };

  services.dwmblocks = {
    blocks = [
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
