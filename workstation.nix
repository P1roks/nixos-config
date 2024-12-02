{ pkgs, ... }:
{
  hardware.printers = {
    ensurePrinters = [
      {
        name = "Lexmark_X364dn";
        location = "Home";
        deviceUri = "usb://Lexmark/X364dn?serial=35092YW&interface=1";
        model = "postscript-lexmark/Lexmark-X364dn-Postscript-Lexmark.ppd";
        ppdOptions = {
          PageSize = "A4";
        };
      }
    ];
  };

  services.printing = {
    enable = true;
    drivers = with pkgs; [
      postscript-lexmark
    ];
  };

  hardware.nvidia = {
    open = true;
  };

  services.xserver = {
    videoDrivers = [ "nvidia" ];
    xrandrHeads = [
      {
        output = "DP-0";
        primary = true;
        monitorConfig = ''
          HorizSync       242.0 - 242.0
          VertRefresh     48.0 - 165.0
          Option         "DPMS"
        '';
      }
      {
        output = "HDMI-0";
      }
    ];
    
    screenSection = ''
      Option         "metamodes" "DP-0: 2560x1440_165 +1920+0, HDMI-0: 1920x1080_60 +0+0"
      DefaultDepth    24
      Option         "Stereo" "0"
      Option         "nvidiaXineramaInfoOrder" "DFP-1"
      Option         "SLI" "Off"
      Option         "MultiGPU" "Off"
      Option         "BaseMosaic" "off"
    '';
  };

  environment.variables = rec {
    VK_DRIVER_FILES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json:/run/opengl-driver-32/share/vulkan/icd.d/nvidia_icd.i686.json";
    VK_ICD_FILENAMES = VK_DRIVER_FILES;
    __GL_SYNC_DISPLAY_DEVICE = "DP-0";
    __GL_SYNC_TO_VBLANK = 0;
    __GL_GSYNC_ALLOWED = 0;
  };

  services.dwmblocks.blocks = [
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
}
