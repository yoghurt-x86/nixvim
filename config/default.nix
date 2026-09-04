{
  pkgs,
  ...
}:

{
  globals.mapleader = " ";

  extraConfigLua = ''
    -- Open image files with sxiv instead of displaying binary
    vim.api.nvim_create_autocmd("BufReadCmd", {
      pattern = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.bmp", "*.svg" },
      callback = function()
        local filename = vim.api.nvim_buf_get_name(0)
        local bufnr = vim.api.nvim_get_current_buf()
        local prev_win = vim.fn.win_getid(vim.fn.winnr('#'))

        -- Open with sxiv detached
        vim.fn.jobstart({"sxiv", filename}, {detach = true})

        -- Schedule buffer cleanup
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(bufnr) then
            pcall(vim.api.nvim_buf_delete, bufnr, {force = true})
          end
          -- Return focus to previous window (nvim-tree)
          if prev_win and prev_win > 0 and vim.api.nvim_win_is_valid(prev_win) then
            vim.api.nvim_set_current_win(prev_win)
          end
        end)
      end
    })
  '';

  opts = {
    number = true;         # Show line numbers
    shiftwidth = 2;        # Tab width should be 2
  };


  keymaps = [
    # Global Mappings
    # Default mode is "" which means normal-visual-op
    {
      # Toggle NvimTree
      key = "<C-n>";
      action = "<CMD>NvimTreeToggle<CR>";
    }
    {
      # Format file
      key = "<space>fm";
      action = "<CMD>lua vim.lsp.buf.format()<CR>";
    }
    {
      # Paste from system clipboard
      key = "<C-p>";
      mode = "n";
      action = "\"+P";
    }
    {
      # Copy to system clipboard
      key = "<C-c>";
      mode = "v";
      action = "\"+y";
    }
  ];

  colorschemes.gruvbox.enable = true;

  plugins.treesitter = {
    enable = true;
    nixGrammars = true;
    settings.indent.enable = true;
    settings.highlight.enable = true;
    grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
      svelte
      gleam
      markdown
      markdown_inline
      c
      cpp
    ];

  };

  plugins.treesitter-context.enable = true;
  plugins.web-devicons.enable = true;

  plugins.nvim-tree = {
      enable = true;
      openOnSetup = true;
      settings = {
        actions.open_file.resize_window = false;
        update_focused_file = {
          enable = true;
          update_root = false;
        };
      };
  };

  plugins.lualine.enable = true;

  plugins.telescope = {
    enable = true;
    keymaps = {
      "<leader>ff" = "find_files";
      "<leader>fg" = "live_grep";
      "<leader>fb" = "buffers";
      "<leader>fh" = "help_tags";
      "<C-p>" = {
        action = "git_files";
	options = {
	  desc = "Telescope Git Files";
	};
      };
    };
    extensions.fzf-native = { enable = true; };
  };

  plugins.lsp = {
    enable = true;

    servers = {
      bashls.enable = true;
      ts_ls.enable = true;
      svelte.enable = true;

      rust_analyzer = {
      	enable = true;
	installRustc = true;
	installCargo = true;
      };
      clangd = { 
	enable = true;
	settings = {
	  cmd = [
	    "clangd"
	    "--background-index"
	    "--clang-tidy"
	  ];
	  filetypes = [
	    "c"
	    "cpp"
	  ];
	  root_markers = [
	    "compile_commands.json"
	    "compile_flags.txt"
	  ];
	};
      };
      zls.enable = true;
      gleam.enable = true;
    };

    keymaps = {  
      lspBuf = {
	K = "hover";
	gD = "references";
	gd = "definition";
	gi = "implementation";
	gt = "type_definition";
	"<leader>rn" = "rename";        # Rename symbol
	"<leader>ca" = "code_action";   # Show code actions
	"<leader>D" = "declaration";    # Go to declaration
      };
      diagnostic = {
	"<leader>e" = "open_float";  # Show error in floating window
	"[d" = "goto_prev";          # Go to previous diagnostic
	"]d" = "goto_next";          # Go to next diagnostic
	"<leader>q" = "setloclist";  # Put all diagnostics in location list
      };
    };
  };

  plugins.cmp = {
    enable = true;
    autoEnableSources = true;

    settings = {
      mapping = {
	"<C-Space>" = "cmp.mapping.complete()";
	"<C-d>" = "cmp.mapping.scroll_docs(-4)";
	"<C-e>" = "cmp.mapping.close()";
	"<C-f>" = "cmp.mapping.scroll_docs(4)";
	"<CR>" = "cmp.mapping.confirm({ select = true })";
	"<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
	"<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
      };
      snippet = {
        expand = "function(args) require('luasnip').lsp_expand(args.body) end";
      };
      sources = [
        {name = "nvim_lsp";}
        {name = "path";}
        {name = "buffer";}
        {name = "luasnip";}
      ];
    };
  };
  plugins.cmp-buffer.enable = true;
  plugins.cmp-nvim-lsp.enable = true; 
  plugins.cmp-path.enable = true;
  plugins.cmp_luasnip.enable = true;
  plugins.luasnip.enable = true;

  # Show available keybindings in popup
  plugins.which-key.enable = true;

  # Diagnostics list view
  plugins.trouble.enable = true;

  # Git signs in gutter
  plugins.gitsigns.enable = true;

  # Auto-close brackets/quotes
  plugins.nvim-autopairs.enable = true;

  # Indent guides
  plugins.indent-blankline.enable = true;

  # LSP progress indicator
  plugins.fidget.enable = true;

  # AI assistant (Cursor-like experience)
  plugins.avante = {
    enable = true;
    # Work around a macOS packaging bug: nixpkgs' avante-nvim derivation copies
    # its native Rust libs with the .dylib extension, but Lua's package.cpath
    # only searches for .so on all platforms. Without this, any AvanteAsk
    # errors with "Make sure to build avante (missing avante_templates)".
    package = pkgs.vimPlugins.avante-nvim.overrideAttrs (old: {
      postInstall =
        (old.postInstall or "")
        + pkgs.lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
          for f in $out/lua/*.dylib; do
            ln -sf "$f" "''${f%.dylib}.so"
          done
        '';
    });
    settings = {
      # LM Studio only runs locally on the macOS machine; fall back to Claude
      # elsewhere (e.g. Linux) so this config stays portable.
      provider =
        if pkgs.stdenv.hostPlatform.isDarwin
        then "lmstudio"
        else "claude";
      providers =
        {
          claude = {
            model = "claude-haiku-3-5-20241022";
            extra_request_body = {
              max_tokens = 4096;
            };
          };
        }
        // pkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
          # Local LM Studio server (OpenAI-compatible API), matching
          # ~/.config/opencode/opencode.jsonc
          lmstudio = {
            __inherited_from = "openai";
            endpoint = "http://127.0.0.1:1234/v1";
            model = "ornith-1.5-35b-a3b-mlx";
            api_key_name = ""; # no auth needed for local server
            extra_request_body = {
              temperature = 0.75;
              max_tokens = 16384;
            };
          };
        };
    };
  };

}

