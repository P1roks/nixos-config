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
  pname = "nblood";
  version = "r14186";

  src = fetchFromGitHub {
    owner = "nukeykt";
    repo = "NBlood";
    rev = "a8c7eedcbaf805da11c2a6051b1692c01151a425";
    hash = "sha256-UwR42VY2WZXUOaSNm4ljhh8tApTvCkqtq9p80b3QdfI=";
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
      name = "nblood";
      icon = "nblood";
      exec = "nblood";
      comment = "Blood port";
      desktopName = "NBlood";
      genericName = "Blood port";
      categories = [ "Game" ];
    })
  ];

  enableParallelBuilding = true;

  installPhase =
    ''
      runHook preInstall

      mv nblood nblood-unwrapped
      install -Dm755 -t $out/bin nblood-unwrapped nblood.pk3
    ''
    + lib.optionalString stdenv.hostPlatform.isLinux ''
      makeWrapper $out/bin/nblood-unwrapped $out/bin/nblood \
        --set-default NBLOOD_DATA_DIR /var/lib/games/nblood \
        --add-flags '-j="$NBLOOD_DATA_DIR"'
      mkdir -p $out/share/icons/hicolor/scalable/apps
      gm convert "./source/blood/rsrc/game_icon.ico" $out/share/icons/hicolor/scalable/apps/nblood.png
    ''
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      mkdir -p $out/Applications/NBlood.app/Contents/MacOS

      cp -r platform/Apple/bundles/NBlood.app/* $out/Applications/Nblood.app/

      ln -sf $out/bin/nblood $out/Applications/NBlood.app/Contents/MacOS/nblood
    ''
    + ''
      runHook postInstall
    '';

  meta = {
    description = "Reverse-engineered port of Blood using EDuke32 engine";
    homepage = "https://github.com/nukeykt/NBlood/tree/master";
    license = with lib.licenses; [ gpl2Plus ];
    platforms = lib.platforms.all;
  };
})
