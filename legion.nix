{ config, pkgs, lib, ... }:
{
  boot.initrd = {
    kernelModules = [ "nvidia" ];
    luks.devices = {
      crypted = {
        device = "/dev/disk/by-uuid/96de9cd5-2227-4372-bbd8-124969e521fd";
        preLVM = true;
      };
    };
  };

  boot.extraModulePackages = with config.boot.kernelPackages; [
    lenovo-legion-module
    nvidia_x11
  ];

  hardware.nvidia = {
    open = false;
    modesetting.enable = false;
    nvidiaSettings = true;
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      # sync.enable = true;
      intelBusId = "PCI:00:02:0";
      nvidiaBusId = "PCI:01:00:0";
    };
  };
  # Some nix setting is implicitly setting nvidia-drm.modeset=1
  # and due to early KMS activation (whatever that means)
  # that borks my system
  # this setting is explicitly setting modeset=0
  # This should've never been done
  # But it was, oh well
  boot.kernelParams = lib.mkForce [
    "loglevel=4"
    "lsm=landlock,yama,bpf"
    "nvidia-drm.modeset=0"
    "nvidia-drm.fbdev=1"
  ];

  boot.extraModprobeConfig = ''
    options nvidia-drm modeset=0
    options nvidia NVreg_DynamicPowerManagement=0x02
  '';

  services.xserver.videoDrivers = [ "modesetting" "nvidia" ];

  # boot.extraModprobeConfig = ''
  #   blacklist nouveau
  #   options nouveau modeset=0
  # '';

  # boot.blacklistedKernelModules = [ "nouveau" "nvidia" "nvidia_drm" "nvidia_modeset" ];
  
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
