{ pkgs, ... }:
{
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
        mode = "n";
        key = "j";
        action = "gj";
        options = { silent = true; desc = "Move down visual line"; };
      }
      {
        mode = "n";
        key = "gj";
        action = "j";
        options = { silent = true; desc = "Move down actual line"; };
      }
      {
        mode = "n";
        key = "k";
        action = "gk";
        options = { silent = true; desc = "Move down visual line"; };
      }
      {
        mode = "n";
        key = "gk";
        action = "k";
        options = { silent = true; desc = "Move up actual line"; };
      }
      {
        mode = "n";
        key = "<leader>x";
        action = "<cmd>Ex<CR>";
        options = { silent = true; desc = "Enter Ex mode"; };
      }
      {
        mode = "n";
        key = "<space>";
        action = "<Nop>";
        options = { silent = true; desc = "unmap space"; };
      }

      # Molten
      {
        mode = "n";
        key = "<leader>mi";
        action = "<cmd>MoltenImportOutput<CR>";
        options = { silent = true; desc = "Molten Import Output"; };
      }
      {
        mode = "n";
        key = "<leader>me";
        action = "<cmd>noautocmd MoltenEnterOutput<CR><cmd>noautocmd MoltenEnterOutput<CR>";
        options = { silent = true; desc = "Molten Enter Output"; };
      }
      {
        mode = "n";
        key = "<leader>mp";
        action = "<cmd>MoltenImagePopup<CR>";
        options = { silent = true; desc = "Molten Image Popup"; };
      }
      {
        mode = "n";
        key = "<leader>ml";
        action = "<cmd>MoltenEvaluateLine<CR>";
        options = { silent = true; desc = "Molten Evaluate Line"; };
      }
      {
        mode = "v";
        key = "<leader>mv";
        action = "<cmd>MoltenEvaluateVisual<CR>gv";
        options = { silent = true; desc = "Molten Evaluate Visual"; };
      }
      {
        mode = "n";
        key = "<leader>md";
        action = "<cmd>MoltenDelete<CR>";
        options = { silent = true; desc = "Molten Delete Output"; };
      }
      {
        mode = "n";
        key = "<leader>mh";
        action = "<cmd>MoltenHideOutput<CR>";
        options = { silent = true; desc = "Molten Hide Output"; };
      }
      {
        mode = "n";
        key = "<leader>ms";
        action = "<cmd>MoltenShowOutput<CR>";
        options = { silent = true; desc = "Molten Show Output"; };
      }
      {
        mode = "n";
        key = "<leader>mr";
        action = "<cmd>MoltenRestart<CR>";
        options = { silent = true; desc = "Molten Restart Kernel"; };
      }

      # Quarto
      {
        mode = "n";
        key = "<leader>qc";
        action = "<cmd>lua require('quarto.runner').run_cell()<CR>";
        options = { silent = true; desc = "Quarto Run Cell"; };
      }
      {
        mode = "n";
        key = "<leader>qa";
        action = "<cmd>lua require('quarto.runner').run_above()<CR>";
        options = { silent = true; desc = "Quarto Run Above"; };
      }
      {
        mode = "n";
        key = "<leader>qA";
        action = "<cmd>lua require('quarto.runner').run_all()<CR>";
        options = { silent = true; desc = "Quarto Run All"; };
      }
    ];

    globals = {
      mapleader = " ";
    };

    autoCmd = [
      # nix & haskell files have 2-width tabs
      {
        event = ["Filetype"];
        pattern = ["nix" "haskell"];
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
      # change working directory to the first opened file directory
      {
        event = ["VimEnter"];
        pattern = [ "*" ];
        command = "cd %:p:h";
      }
      # add \lF command to VimTex
      {
        event = ["Filetype"];
        pattern = ["tex" "latex"];
        command = "nnoremap <silent><buffer> \\lF <cmd>VimtexStop<CR><cmd>execute 'silent !rm ' . get(g:vimtex_compiler_latexmk, 'out_dir', '.') . '/*.synctex.gz 2>/dev/null'<CR><cmd>VimtexClean<CR>";
      }
      # Export jupyter notebook after saving
      {
        event = ["BufWritePost"];
        pattern = ["*.ipynb"];
        command = "MoltenExportOutput!";
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
          fileTypes = [ "*" ];

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

      vimtex = {
        enable = true;
        settings = {
          view_method = "sioyek";
          compiler_latexmk = {
            aux_dir = ".texaux";
            engines = {
              "_" = "-lualatex";
            };
            options = [
              "-verbose"
              "-file-line-error"
              "-synctex=1"
              "-interaction=nonstopmode"
              "-shell-escape"
            ];
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
            "bash" "fish"
            "haskell" "nix"
            "yaml" "toml" "json"
            "html" "css" "scss"
            "javascript" "typescript" "tsx"
            "c" "cpp" "rust"
            "kotlin" "scala" "java"
            "make" "cmake"
            "markdown"
          ];
          ignore_install = [
            "tex"
            "latex"
          ];
          highlight = {
            enable = true;
            disable = [ "latex" "tex" ];
          };
          incremental_selection.enable = true;
          indent = {
            enable = true;
            disable = [ "latex" "tex" ];
          };
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
          # "\\lF".action = "<cmd>VimtexStop | execute 'silent !mv build/*.pdf . 2>/dev/null' | VimtexClean!<CR>";
        };
      };

      luasnip = {
        enable = true;
        fromVscode = [ {} ];
      };

      image =
      let
        package = pkgs.vimPlugins.image-nvim.overrideAttrs (finalAttrs: prevAttrs: {
          version = "1.5.1";

            src = pkgs.fetchFromGitHub {
              owner = "3rd";
              repo = "image.nvim";
              tag = "v${finalAttrs.version}";
              hash = "sha256-brDtVYD3O+7N2RdQPIx2+6P+faXafoJDUITy0z0cIuA=";
            };
        });
      in 
      {
        enable = true;
        package = package;
        settings = {
          backend = "kitty";
          max_height = 800;
          max_width = 81;
          max_height_window_percentage.__raw = "math.huge";
          max_width_window_percentage.__raw = "math.huge";
          window_overlap_clear_enabled = true;
          window_overlap_clear_ft_ignore = ["cmp_menu" "cmp_docs" ""];
        };
      };

      otter = {
        enable = true;
      };

      quarto = {
        enable = true;

        settings = {
          codeRunner = {
            enabled = true;
            default_method = "molten";
          };

          lspFeatures = {
            languages = ["python" "r" "julia" "bash" "html"];
            diagnostics.enabled = true;
            completion.enabled = true;
          };
        };
      };

      jupytext = {
        enable = true;
        settings = {
          force_ft = "quarto";
          output_extension = "qmd";
          style = "quarto";
        };
      };

      molten = {
        enable = true;

        settings = {
          image_provider = "image.nvim";
          auto_open_output = false;
          wrap_output = true;
          virt_text_output = true;
          virt_lines_off_by_1 = true;
          output_win_cover_gutter = false;
        };

        python3Dependencies = python_pkgs: with python_pkgs; [
          pynvim
          jupyter-client
          cairosvg
          ipython
          nbformat
          ipykernel
          pnglatex
        ];
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
            gR = "rename";
            gC = "code_action";
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
          jdtls.enable = true;

          hls = {
            enable = true;
            installGhc = true;
          };

          nixd = {
            enable = true;
            settings = {
              nixpkgs.expr = "import inputs.nixpkgs {}";
              formatting.command = [ "nixpkgs-fmt" ];
            };
          };

          clangd = {
            enable = true;
            extraOptions = {
              init_options = {
                fallbackFlags = ["--std=c++23"];
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
