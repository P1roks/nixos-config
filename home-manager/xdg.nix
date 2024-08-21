{pkgs, config, ...}:
let
  home = "${config.home.homeDirectory}";
in 
{
  xdg = {
    enable = true;

    desktopEntries = {
      ranger-open =
      let
        alacritty = "${pkgs.alacritty}/bin/alacritty";
        ranger = "${pkgs.ranger}/bin/ranger";
      in {
        type = "Application";
        name = "ranger";
        terminal = false;
        exec = "${alacritty} -e ${ranger} %f";
        categories = [ "ConsoleOnly" "System" "FileTools" "FileManager" ];
        mimeType = [ "inode/directory" ];
        settings = {
          Keywords = "File;Manager;Browser;Explorer;Launcher;Vi;Vim;Python";
        };
      };

      mpv-audio-open =
      let
        alacritty = "${pkgs.alacritty}/bin/alacritty";
        mpv = "${pkgs.mpv}/bin/mpv";
      in {
        type = "Application";
        name = "mpv-audio-open";
        terminal = false;
        exec = "${alacritty} -e ${mpv} --no-video %f";
        categories = [ "ConsoleOnly" "System" "FileTools" "FileManager" ];
        mimeType = [ "audio/aac" "audio/midi" "audio/x-midi" "audio/mpeg" "audio/ogg" "audio/wav" "audio/webm" "audio/3gpp" "audio/3gpp2" ];
      };

      mpv-audio =
      let
        mpv = "${pkgs.mpv}/bin/mpv";
      in {
        type = "Application";
        name = "mpv-audio";
        terminal = true;
        exec = "${mpv} --no-video %f";
        categories = [ "ConsoleOnly" "System" "FileTools" "FileManager" ];
        mimeType = [ "audio/aac" "audio/midi" "audio/x-midi" "audio/mpeg" "audio/ogg" "audio/wav" "audio/webm" "audio/3gpp" "audio/3gpp2" ];
      };
    };

    mimeApps = {
      enable = true;
      defaultApplications = {
        "inode/directory" = [ "ranger-open.desktop" ];
        "audio/aac" = [ "mpv-audio-open.desktop" ];
        "audio/midi" = [ "mpv-audio-open.desktop" ];
        "audio/x-midi" = [ "mpv-audio-open.desktop" ];
        "audio/mpeg" = [ "mpv-audio-open.desktop" ];
        "audio/ogg" = [ "mpv-audio-open.desktop" ];
        "audio/wav" = [ "mpv-audio-open.desktop" ];
        "audio/webm" = [ "mpv-audio-open.desktop" ];
        "audio/3gpp" = [ "mpv-audio-open.desktop" ];
        "audio/3gpp2" = [ "mpv-audio-open.desktop" ];
        "image/avif" = [ "sxiv.desktop" ];
        "image/bmp" = [ "sxiv.desktop" ];
        "image/gif" = [ "sxiv.desktop" ];
        "image/jpeg" = [ "sxiv.desktop" ];
        "image/jpg" = [ "sxiv.desktop" ];
        "image/png" = [ "sxiv.desktop" ];
        "image/webp" = [ "sxiv.desktop" ];
        "image/tiff" = [ "sxiv.desktop" ];
        "image/x-bmp" = [ "sxiv.desktop" ];
        "image/x-portable-anymap" = [ "sxiv.desktop" ];
        "image/x-portable-bitmap" = [ "sxiv.desktop" ];
        "image/x-portable-graymFap" = [ "sxiv.desktop" ];
        "image/x-tga" = [ "sxiv.desktop" ];
        "image/x-xpixmap" = [ "sxiv.desktop" ];
        "text/x-dbus-service" = [ "nvim.desktop" ];
        "text/english" = [ "nvim.desktop" ];
        "text/plain" = [ "nvim.desktop" ];
        "text/x-makefile" = [ "nvim.desktop" ];
        "text/x-lua" = [ "nvim.desktop" ];
        "text/x-c++hdr" = [ "nvim.desktop" ];
        "text/x-c++src" = [ "nvim.desktop" ];
        "text/x-chdr" = [ "nvim.desktop" ];
        "text/x-csrc" = [ "nvim.desktop" ];
        "text/x-java" = [ "nvim.desktop" ];
        "text/x-moc" = [ "nvim.desktop" ];
        "text/x-pascal" = [ "nvim.desktop" ];
        "text/x-tcl" = [ "nvim.desktop" ];
        "text/x-tex" = [ "nvim.desktop" ];
        "application/x-shellscript" = [ "nvim.desktop" ];
        "application/sql" = [ "nvim.desktop" ];
        "text/x-c" = [ "nvim.desktop" ];
        "text/x-c++" = [ "nvim.desktop" ];
      };
    };

    userDirs = {
      enable = true;
      desktop = "${home}/desktop";
      documents = "${home}/documents";
      download = "${home}/downloads";
      music = "${home}/music";
      pictures = "${home}/pictures";
      videos = "${home}/videos";
      publicShare = "${home}/public";
      templates = "${home}/templates";
      extraConfig = {
        XDG_GAMES_DIR = "${home}/games";
      };
    };
  };
}
