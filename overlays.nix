{lib, ...}:
{
  nixpkgs.overlays = [
    (final: prev: {
      gemini-cli-bin = prev.gemini-cli-bin.overrideAttrs (finalAttrs: prevAttrs: {
        version = "0.33.1";

        src = prev.fetchurl {
          url = "https://github.com/google-gemini/gemini-cli/releases/download/v${finalAttrs.version}/gemini.js";
          sha256 = "AWsXfHOfd5HoseqacmfkO+vuJStuG2vLysd0EUyF2f8=";
        };

        nativeBuildInputs = [final.makeWrapper];

        buildInputs = (prevAttrs.buildInputs or []) ++ [final.ripgrep final.nodejs];

          installPhase = ''
            runHook preInstall
            local dest="$out/lib/gemini/gemini.js"
            install -Dm644 "$src" "$dest"
            sed -i '/enableAutoUpdate: {/,/}/ s/default: true/default: false/' "$dest"
            substituteInPlace "$dest" \
              --replace-fail 'const existingPath = await resolveExistingRgPath();' 'const existingPath = "${lib.getExe final.ripgrep}";'
            makeWrapper "${lib.getExe final.nodejs}" "$out/bin/gemini" \
              --add-flags "--no-warnings=DEP0040" \
              --add-flags "$dest"

            runHook postInstall
          '';
      });
    })
    (final: prev: {
      mkJupyterShell = {name ? "nix-shell-python", packages ? (ps: []), ...} @ args:
      let
        pythonEnv = final.python313.withPackages (ps: (packages ps) ++ [ ps.ipykernel ]);   

        jupyterKernel = final.writeTextDir "kernels/${name}/kernel.json" (builtins.toJSON {
          display_name = name;
          language = "python";
          argv = [
            "${pythonEnv}/bin/python"
            "-m"
            "ipykernel_launcher"
            "-f"
            "{connection_file}"
          ];
        });

        shellArgs = builtins.removeAttrs args [ "name" "packages" ];
      in 
      final.mkShell (shellArgs // {
          packages = (shellArgs.packages or []) ++ [ pythonEnv ];
          shellHook = (shellArgs.shellHook or "") + ''
            export JUPYTER_PATH="${jupyterKernel}''${JUPYTER_PATH:+:$JUPYTER_PATH}"
            export PYTHONPATH="${pythonEnv}/${final.python313.sitePackages}''${PYTHONPATH:+:$PYTHONPATH}"
            export LD_LIBRARY_PATH="${final.lib.makeLibraryPath [ final.stdenv.cc.cc.lib final.zlib ]}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
          '';
      });
  })
  (final: prev: {
      rars = prev.rars.overrideAttrs(finalAttrs: prevAttrs: {
        version = "1.7";

        src = prev.fetchurl {
          url = "https://github.com/rarsm/rars/releases/download/v1.7/rars-1.7.jar";
          hash = "sha256-4SBg2Wg+bPUO/siQCqmsyiqGg4lnr4xj+RamYBi4hKQ=";
        };
      });
  })
  ];
}
