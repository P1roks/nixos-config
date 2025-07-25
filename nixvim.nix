{ pkgs, ... }:
let
  nixvim = import (builtins.fetchGit {
    url = "https://github.com/nix-community/nixvim";
    ref = "nixos-25.05";
  });
in
{
  imports = [
    nixvim.nixosModules.nixvim
  ];

  programs.nixvim = {
    enable = true;
    enableMan = true;
    vimAlias = true;

    colorschemes.gruvbox.enable = true;

    opts = {
      number = true;
      relativenumber = true;
      ignorecase = true;
      smartcase = true;
      showmode = false;
      tabstop = 4;
      shiftwidth = 4;
      expandtab = true;
    };

    keymaps = [
      {
        key = "j";
        action = "gj";
        mode = "n";
      }
      {
        key = "gj";
        action = "j";
        mode = "n";
      }
      {
        key = "k";
        action = "gk";
        mode = "n";
      }
      {
        key = "gk";
        action = "k";
        mode = "n";
      }
      {
        key = "<space>";
        action = "<Nop>";
        mode = "n";
      }
    ];

    globals = {
      mapleader = " ";
    };

    autoCmd = [
      # nix config files have 2-width tabs
      {
        event = ["Filetype"];
        pattern = ["nix"];
        command = "setlocal tabstop=2 shiftwidth=2";
      }
      # autocompile scss (style.s[c|a]ss file)
      {
        event = ["BufWritePost"];
        pattern = ["*.scss" "*.sass"];
        command = "silent exec \"!${pkgs.sass}/bin/sass %:p:h/style.%:e %:p:h/style.css\"";
      }
      # use html treesitter for template engines
      {
        event = [ "BufRead" "BufNewFile" ];
        pattern = [ "*.ejs" "*.handlebars" "*.hbs"];
        command = "set filetype=html";
      }

      # Change working directory to the first opened file directory
      {
        event = ["VimEnter"];
        pattern = [ "*" ];
        command = "cd %:p:h";
      }
    ];

    diagnostic.settings = {
      virtual_text = true;
      signs = false;
    };

    plugins = {
      nvim-autopairs.enable = true;
      comment.enable = true;
      mini.enable = true;
      web-devicons.enable = true;

      colorizer = {
        enable = true;

        settings = {
          fileTypes = [
            "*"
            # css = {
            #  names = true;
            #  css = true;
            # }
            # scss = {
            #  names = true;
            #  css = true;
            # }
          ];

          userDefaultOptions = {
            RGB = true;
            RRGGBB = true;
            names = false;
            RRGGBBAA = true;
            AARRGGBB = true;
          };
        };
      };

      indent-blankline = {
        enable = true;

        settings = {
          indent.tab_char = "⇥";
        };
      };

      lualine = {
        enable = true;
        settings = {
          options = {
            theme = "gruvbox-material";
          };
          sections = {
            lualine_x = [ "encoding" "filetype" ];
          };
        };
      };

      treesitter = {
        enable = true;
        nixGrammars = true;
        nixvimInjections = true;
        settings = {
          auto_install = true;
          ensure_installed = [
            "diff" "dockerfile" "awk"
            "bash" "fish" "nix"
            "yaml" "toml" "json"
            "html" "css" "scss"
            "javascript" "typescript" "tsx"
            "c" "cpp" "rust"
            "kotlin" "scala" "java"
            "make" "cmake"
          ];
          highlight.enable = true;
          incremental_selection.enable = true;
          indent.enable = true;
        };
      };

      telescope = {
        enable = true;
        keymaps = {
            "<c-p>".action = "find_files";
            "<a-p>".action = "oldfiles";
            gl.action = "treesitter";
            gr.action = "lsp_references";
            gi.action = "lsp_implementations";
            gd.action = "lsp_definitions";
            gt.action = "lsp_type_definitions";
        };
      };

      luasnip = {
        enable = true;
        fromVscode = [ {} ];
      };

      cmp_luasnip.enable = true;
      cmp-nvim-lsp.enable = true;
      cmp-buffer.enable = true;
      cmp-path.enable = true;
      cmp = {
        enable = true;
        autoEnableSources = true;

        settings = {
          snippet.expand = ''
            function(args)
              require('luasnip').lsp_expand(args.body)
            end
          '';

          sources = [
            { name = "nvim_lsp"; }
            { name = "luasnip"; }
            { name = "buffer"; }
            { name = "path"; }
          ];

          mapping = {
            "<Enter>" = "cmp.mapping.confirm({ select = true })";
            "<C-e>" = "cmp.mapping.close()";
            "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
            "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<C-b>" = "cmp.mapping.scroll_docs(4)";
          };

          experimental = {
            ghost_text = true;
          };
        };
      };

      lsp = {
        enable = true;
        inlayHints = true;

        keymaps = {
          lspBuf = {
            gD = "declaration";
            K = "hover";
            "gR" = "rename";
          };
          diagnostic = {
            "<leader>e" = "open_float";
            ge = "goto_next";
            gE = "goto_prev";
          };
        };

        servers = {
          cssls.enable = true;
          bashls.enable = true;
          emmet_ls.enable = true;
          texlab.enable = true;
          pyright.enable = true;

          nixd = {
            enable = true;
            settings = {
              nixpkgs.expr = "import <nixpkgs> { }";
              formatting.command = [ "nixpkgs-fmt" ];
            };
          };

          clangd = {
            enable = true;
            extraOptions = {
              init_options = {
                fallbackFlags = ["--std=c++20"];
              };
            };
          };

          ts_ls =
          let inlay_hints_settings = {
            includeInlayParameterNameHints = "all";
            includeInlayParameterNameHintsWhenArgumentMatchesName = true;
            includeInlayFunctionParameterTypeHints = true;
            includeInlayVariableTypeHints = true;
            includeInlayPropertyDeclarationTypeHints = true;
            includeInlayFunctionLikeReturnTypeHints = true;
            includeInlayEnumMemberValueHints = true;
            importModuleSpecifierPreference = "non-relative";
          }; in {
            enable = true;
            settings = {
                typescript.inlayHints = inlay_hints_settings;
                javascript.inlayHints = inlay_hints_settings;
            };
          };

          rust_analyzer = {
            enable = true;
            installCargo = true;
            installRustc = true;
          };

          volar = {
            enable = true;
          };
        };
      };
    };

    extraPlugins = with pkgs.vimPlugins; [
      {
        plugin = nvim-surround;
        config = ''lua require("nvim-surround").setup({})'';
      }
      {
        plugin = friendly-snippets;
      }
    ];
  };
}
