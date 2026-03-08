{lib, ...}:
{
  nixpkgs.overlays = [
    (final: prev: {
      gemini-cli-bin = prev.gemini-cli-bin.overrideAttrs (finalAttrs: prevAttrs: {
        version = "0.30.0";

        src = prev.fetchurl {
          url = "https://github.com/google-gemini/gemini-cli/releases/download/v${finalAttrs.version}/gemini.js";
          sha256 = "N4pfjiaawx8kvaOFoQ53owJehD69fECJPpt5DxKVJ7k=";
        };

        buildInputs = (prevAttrs.buildInputs or []) ++ [final.ripgrep];

        installPhase = ''
          runHook preInstall
          install -D "$src" "$out/bin/gemini"
          sed -i '/enableAutoUpdate: {/,/}/ s/default: true/default: false/' "$out/bin/gemini"
          substituteInPlace $out/bin/gemini \
            --replace-fail 'const existingPath = await resolveExistingRgPath();' 'const existingPath = "${lib.getExe final.ripgrep}";'
          runHook postInstall
        '';
      });
    })
  ];
}
