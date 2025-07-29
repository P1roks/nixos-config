{
  stdenvNoCC,
  lib,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "VHS-font";
  version = "1.20";
  src = ./VHS.ttf; #https://www.dafont.com/minecraft.font

  phases = ["installPhase"];

  installPhase = ''
    mkdir -p $out/share/fonts/truetype/VCR
    cp $src $out/share/fonts/truetype/VCR/
  '';

  meta = with lib; {
    description = "VHS font";
    homepage = "https://www.dafont.com/vcr-osd-mono.font";
    platforms = platforms.all;
  };
}
