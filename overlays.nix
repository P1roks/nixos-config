{...}:
{
  nixpkgs.overlays = [
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
