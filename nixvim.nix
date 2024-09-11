{ pkgs, ... }:
let
    nixvim = import (builtins.fetchGit {
      url = "https://github.com/nix-community/nixvim";
      ref = "nixos-24.05";
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

    globals = {
      mapleader = "<Space>";
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
    ];

    autoCmd = [
      # nix config files have 2-width tabs
      {
        event = ["Filetype"];
        pattern = ["nix"];
        command = "setlocal tabstop=2 shiftwidth=2";
      }
      # autocompile scss
      {
        event = ["BufWritePost"];
        pattern = ["*.scss" "*.sass"];
        command = "silent exec \"!${pkgs.sass}/bin/sass %:p %:r.css\"";
      }
    ];

    plugins = {
      nvim-autopairs.enable = true;
      comment.enable = true;
      mini.enable = true;

      nvim-colorizer = {
        enable = true;

        fileTypes = [
          "*"
          {
            language = "css";
            names = true;
            css = true;
          }
          {
            language = "scss";
            names = true;
            css = true;
          }
        ];

        userDefaultOptions = {
          RGB = true;
          RRGGBB = true;
          names = false;
          RRGGBBAA = true;
          AARRGGBB = true;
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
        theme = "gruvbox-material";
        sections = {
          lualine_x = [ "encoding" "filetype" ];
        };
      };

      treesitter = {
        enable = true;
        nixGrammars = true;
        nixvimInjections = true;
        ensureInstalled = [
          "diff" "dockerfile" "awk"
          "bash" "fish" "nix"
          "yaml" "toml" "json"
          "html" "css" "scss"
          "javascript" "typescript" "tsx"
          "c" "cpp" "rust"
          "kotlin" "scala" "java"
          "make" "cmake"
        ];
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

        keymaps = {
          lspBuf = {
            gD = "declaration";
            K = "hover";
            "gR" = "rename";
          };
        };

        servers = {
          cssls.enable = true;
          clangd.enable = true;
          tsserver.enable = true;
          nixd.enable = true;
          bashls.enable = true;
          emmet-ls.enable = true;
          #rust-analyzer = {
          #  enable = true;
          #};
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
      {
        plugin = pkgs.vimUtils.buildVimPlugin {
          name = "render-markdown";
          src = pkgs.fetchFromGitHub {
            owner = "MeanderingProgrammer";
            repo = "render-markdown.nvim";
            rev = "11b92a6be7e3d848d4f7467f6edb5578c60bcad2";
            sha256 = "sZIOdcZ6pchu6wMo7THaRV6TG9rEnnpe6iUyHZPHf5c=";
          };
        };
        config = ''
        lua << EOF
          require('render-markdown').setup({
            file_types = { 'markdown' },
            render_modes = { 'n', 'c' },
            overrides = {
             buftype = {
              nofile = {
                sign = { enabled = false },
              },
             },
            },
          })
        EOF
        '';
      }
    ];
  };
}
