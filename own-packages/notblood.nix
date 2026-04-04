{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  pkg-config,
  nasm,
  makeDesktopItem,
  copyDesktopItems,
  alsa-lib,
  flac,
  gtk2,
  libvorbis,
  libvpx,
  libGL,
  SDL2,
  SDL2_mixer,
  timidity,
  darwin,
  graphicsmagick,
  ...
}:
let
  inherit (darwin.apple_sdk.frameworks)
    AGL
    Cocoa
    GLUT
    OpenGL
    ;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "notblood";
  version = "459ad1a";

  src = fetchFromGitHub {
    owner = "clipmove";
    repo = "NotBlood";
    rev = "459ad1a390038500cf9c6fa75502dbe7437ee57d";
    hash = "sha256-tm3EsebOMq26OFtYgf3/Mg/KIqkRmLH/higJzaRSLmM=";
  };

  patches = [
    # gdk-pixbuf-csource no longer supports bmp so convert to png
    # patch GNUMakefile to use graphicsmagick to convert bmp -> png
    ./convert-bmp-to-png.diff
  ];

  buildInputs =
    [
      flac
      libvorbis
      libvpx
      SDL2
      SDL2_mixer
      timidity
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      alsa-lib
      gtk2
      libGL
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      AGL
      Cocoa
      GLUT
      OpenGL
    ];

  nativeBuildInputs =
    [
      makeWrapper
      pkg-config
      copyDesktopItems
      graphicsmagick
    ]
    ++ lib.optionals (stdenv.hostPlatform.system == "i686-linux") [
      nasm
    ];

  postPatch =
    ''
      substituteInPlace source/imgui/src/imgui_impl_sdl2.cpp \
        --replace-fail '#include <SDL.h>' '#include <SDL2/SDL.h>' \
        --replace-fail '#include <SDL_syswm.h>' '#include <SDL2/SDL_syswm.h>' \
        --replace-fail '#include <SDL_vulkan.h>' '#include <SDL2/SDL_vulkan.h>'
    ''
    + lib.optionalString stdenv.hostPlatform.isLinux ''
      for f in glad.c glad_wgl.c ; do
        substituteInPlace source/glad/src/$f \
          --replace-fail libGL.so ${libGL}/lib/libGL.so
      done
    '';

  makeFlags = [
    "SDLCONFIG=${SDL2}/bin/sdl2-config"
    # git rev-list --count HEAD
    "VC_REV=10593"
    "VC_HASH=${lib.substring 0 9 finalAttrs.src.rev}"
    "VC_BRANCH=master"
  ];

  buildFlags = [
    "blood"
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "notblood";
      icon = "notblood";
      exec = "notblood";
      comment = "Blood port";
      desktopName = "NotBlood";
      genericName = "Blood port";
      categories = [ "Game" ];
    })
  ];

  enableParallelBuilding = true;

  installPhase =
    ''
      runHook preInstall

      mv notblood notblood-unwrapped
      install -Dm755 -t $out/bin notblood-unwrapped
      install -Dm644 -t $out/lib notblood.pk3
    ''
    + lib.optionalString stdenv.hostPlatform.isLinux ''
      makeWrapper $out/bin/notblood-unwrapped $out/bin/notblood \
        --set-default DATA_FILE $out \
        --add-flags '-j="/var/lib/games/notblood"' \
        --add-flags '-j="$DATA_FILE/lib"'
      mkdir -p $out/share/icons/hicolor/scalable/apps
      gm convert "./source/blood/rsrc/game_icon.ico" $out/share/icons/hicolor/scalable/apps/notblood.png
    ''
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      mkdir -p $out/Applications/NotBlood.app/Contents/MacOS

      cp -r platform/Apple/bundles/NotBlood.app/* $out/Applications/Notblood.app/

      ln -sf $out/bin/notblood $out/Applications/NotBlood.app/Contents/MacOS/notblood
    ''
    + ''
      runHook postInstall
    '';

  meta = {
    description = "Reverse-engineered port of Blood using EDuke32 engine";
    homepage = "https://github.com/clipmove/NotBlood";
    license = with lib.licenses; [ gpl2Plus ];
    platforms = lib.platforms.all;
  };
})
