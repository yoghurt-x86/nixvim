{pkgs, ...}:

{
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
    indent = true;
  };

  plugins.treesitter-context.enable = true;

  plugins.nvim-tree = {
      enable = true;
      openOnSetup = true;
  };

  plugins.lualine.enable = true;

  plugins.telescope = {
    enable = true;
    keymaps = {
      "<leader>fg" = "live_grep";
      "<C-p>" = {
        action = "git_files";
        desc = "Telescope Git Files";
      };
    };
    extensions.fzf-native = { enable = true; };
  };

  plugins.lsp = {
    enable = true;

    servers = {
      bashls.enable = true;
      tsserver.enable = true;
      tsserver.extraOptions = {
        settings = {
          typescript = {
            format.semicolons = "remove";
          };
        };
      };
    };

    keymaps.lspBuf = {
      K = "hover";
      gD = "references";
      gd = "definition";
      gi = "implementation";
      gt = "type_definition";
    };
  };
}

