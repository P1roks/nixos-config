{
  stdenvNoCC,
  lib,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "minecraft-font";
  version = "1.20";
  src = ./minecraft.ttf; #https://www.dafont.com/minecraft.font

  phases = ["installPhase"];

  installPhase = ''
    mkdir -p $out/share/fonts/truetype/Minecraft
    cp $src $out/share/fonts/truetype/Minecraft/
  '';

  meta = with lib; {
    description = "Minecraft font";
    homepage = "minecraft.com";
    platforms = platforms.all;
  };
}
