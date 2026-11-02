{
  pkgs,
  config,
  stateVersion,
  minimal ? false,
  ...
}:
let
  cliPackages = with pkgs; [
    # Shell / Navigation
    fzf
    tmux
    twm
    ripgrep
    yazi
    btop
    fastfetch
    # System / Network
    sshfs
    picocom
    miniserve
    # Debug / Trace
    gdb
    lldb
    valgrind
    perf
    gf
    # VCS
    git
    github-cli
    # Cache
    sccache

    claude-code
    opencode
  ];

  guiPackages = with pkgs; [
    ghostty
    feh
    zathura
    sqlitebrowser
  ];

  themePackages = with pkgs; [
    dconf
    papirus-icon-theme
    nerd-fonts.jetbrains-mono
  ];

  profilingPackages = with pkgs; [
    hotspot
    heaptrack
    hyperfine
    poop
  ];

  cadPackages = with pkgs; [
    (pkgs.symlinkJoin {
      name = "freecad-wrapped";
      paths = [ freecad ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram "$out/bin/freecad" --set QT_QPA_PLATFORM xcb
      '';
    })
    (pkgs.symlinkJoin {
      name = "kicad-wrapped";
      paths = [ kicad ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram "$out/bin/kicad" --set GDK_BACKEND x11
      '';
    })
    orca-slicer
  ];

  miscPackages = with pkgs; [
    gimp
    darktable
    (discord.override {
      withOpenASAR = true;
      withVencord = true;
    })
    spotify
    vlc
    prismlauncher
    slack
    libreoffice
    obs-studio
    kdePackages.kdenlive
    tenacity

  ];

  selectedPackages =
    if minimal then
      cliPackages ++ themePackages
    else
      cliPackages ++ guiPackages ++ themePackages ++ profilingPackages ++ cadPackages ++ miscPackages;

  dotfilesPath = "${config.home.homeDirectory}/.dotfiles";

  sharedAliases = {
    # Generic Aliases
    nxh = "nix develop -c hx";
    nxv = "nix develop -c nvim";
    nxd = "nix develop";
  };

  sharedSessionVariables = {
    SHELL = "${pkgs.bash}/bin/bash";
    EDITOR = "hx";
    GIT_EDITOR = "hx";
    DOTFILES = dotfilesPath;
    BROWSER = "chromium";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    RUSTC_WRAPPER = "sccache";
  };
in
{
  home.stateVersion = stateVersion;

  home.packages = selectedPackages;
  fonts.fontconfig.enable = true;

  home.shellAliases = sharedAliases;
  home.sessionVariables = sharedSessionVariables;

  programs = {
    chromium = {
      enable = true;
    };

    helix = {
      enable = true;
      extraPackages = with pkgs; [
        nil
        nixfmt
        prettier
      ];
    };

    neovim = {
      enable = true;
      defaultEditor = false;
      viAlias = true;
      vimAlias = true;
      withPython3 = true;
      withRuby = false;

      extraPackages = with pkgs; [
        nil
        nixfmt
        lua-language-server
        ripgrep
        fd
      ];

      plugins = with pkgs.vimPlugins; [
        {
          plugin = kanagawa-nvim;
          type = "lua";
          config = ''
            require('kanagawa').setup{
              theme = 'dragon',
              transparent = false,
              terminalColors = true,
              keywordStyle = { italic = true },
            }
            vim.cmd('colorscheme kanagawa-dragon')
          '';
        }
        {
          plugin = telescope-nvim;
          type = "lua";
          config = ''
            require('telescope').setup{}
            vim.keymap.set('n', '<leader>ff', require('telescope.builtin').find_files)
            vim.keymap.set('n', '<leader>fg', require('telescope.builtin').live_grep)
            vim.keymap.set('n', '<leader>fb', require('telescope.builtin').buffers)
          '';
        }
        plenary-nvim
        {
          plugin = harpoon2;
          type = "lua";
          config = ''
            local harpoon = require('harpoon')
            harpoon:setup()

            vim.keymap.set('n', '<leader>e', function() harpoon:list():add() end)
            vim.keymap.set('n', '<leader>h', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

            vim.keymap.set('n', '<leader>1', function() harpoon:list():select(1) end)
            vim.keymap.set('n', '<leader>2', function() harpoon:list():select(2) end)
            vim.keymap.set('n', '<leader>3', function() harpoon:list():select(3) end)
            vim.keymap.set('n', '<leader>4', function() harpoon:list():select(4) end)
          '';
        }
        {
          plugin = nvim-treesitter.withAllGrammars;
          type = "lua";
          config = ''
            vim.api.nvim_create_autocmd('FileType', {
              pattern = '*',
              callback = function()
                pcall(vim.treesitter.start)
              end,
            })
          '';
        }
        {
          plugin = nvim-lspconfig;
          type = "lua";
          config = ''
            local servers = {
              nil_ls = 'nil',
              lua_ls = 'lua-language-server',
              rust_analyzer = 'rust-analyzer',
              pyright = 'pyright-langserver',
              ts_ls = 'typescript-language-server',
              gopls = 'gopls',
              clangd = 'clangd',
              zls = 'zls',
            }

            for server, cmd in pairs(servers) do
              if vim.fn.executable(cmd) == 1 then
                vim.lsp.enable(server)
              end
            end

            vim.lsp.config('rust_analyzer', {
              settings = {
                ['rust-analyzer'] = {
                  check = {
                    command = 'clippy',
                  },
                },
              },
            })

            vim.lsp.config('nil_ls', {
              settings = {
                ['nil'] = {
                  nix = {
                    flake = {
                      autoArchive = true,
                    },
                  },
                },
              },
            })

            vim.api.nvim_create_autocmd('LspAttach', {
              callback = function(args)
                local opts = { buffer = args.buf }
                vim.keymap.set('n', '<leader>k', vim.lsp.buf.hover, opts)
                vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
                vim.keymap.set('n', 'gy', vim.lsp.buf.type_definition, opts)
                vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
                vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
                vim.keymap.set('n', '<leader>a', vim.lsp.buf.code_action, opts)
                vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename, opts)
                vim.keymap.set('n', '<leader>d', require('telescope.builtin').diagnostics, opts)
                vim.keymap.set('n', '<leader>s', require('telescope.builtin').lsp_document_symbols, opts)
                vim.keymap.set('n', '<leader>S', require('telescope.builtin').lsp_dynamic_workspace_symbols, opts)
                vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help, opts)
                vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
                vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
              end,
            })
          '';
        }
        nvim-web-devicons
        {
          plugin = lualine-nvim;
          type = "lua";
          config = ''
            require('lualine').setup({
              options = {
                icons_enabled = true,
                theme = 'auto',
                component_separators = { left = "", right = "" },
                section_separators = { left = "", right = "" },
                disabled_filetypes = {
                  statusline = {},
                  winbar = {},
                },
                always_divide_middle = true,
                globalstatus = false,
                refresh = {
                  statusline = 1000,
                  tabline = 1000,
                  winbar = 1000,
                },
              },
              sections = {
                lualine_a = { 'mode' },
                lualine_b = { 'branch', 'diff', 'diagnostics' },
                lualine_c = { 'filename' },
                lualine_x = { 'encoding', { 'fileformat', icons_enabled = false }, 'filetype' },
                lualine_y = { 'location' },
                lualine_z = { 'hostname' },
              },
              inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = { 'filename' },
                lualine_x = { 'location' },
                lualine_y = {},
                lualine_z = {},
              },
              tabline = {},
            })
          '';
        }
      ];

      initLua = ''
        vim.g.mapleader = ' '
        vim.diagnostic.config({
          virtual_text = false,
          virtual_lines = { current_line = true },
        })
        vim.opt.number = true
        vim.opt.relativenumber = true
        vim.opt.expandtab = true
        vim.opt.shiftwidth = 2
        vim.opt.tabstop = 2
        vim.opt.ignorecase = true
        vim.opt.smartcase = true
        vim.opt.termguicolors = true
      '';
    };

    bash = {
      enable = true;
      sessionVariables = sharedSessionVariables;
      enableCompletion = true;
      historyControl = [
        "ignoredups"
        "ignorespace"
      ];
    };

    carapace = {
      enable = true;
      enableBashIntegration = true;
    };

    starship = {
      enable = true;
      settings = {
        add_newline = true;
        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[➜](bold red)";
        };
      };
    };
  };

  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };
  };

  xdg = {
    enable = true;

    desktopEntries = {
      feh = {
        name = "Feh";
        exec = "feh %f";
        mimeType = [
          "image/jpeg"
          "image/png"
          "image/gif"
        ];
      };
    };

    mime.enable = true;

    mimeApps = {
      enable = true;
      defaultApplications = {
        "application/pdf" = "zathura.desktop";

        "image/jpeg" = "feh.desktop";
        "image/png" = "feh.desktop";
        # chromium as Browser
        "default-web-browser" = "chromium.desktop";
        "text/html" = "chromium.desktop";
        "x-scheme-handler/http" = "chromium.desktop";
        "x-scheme-handler/https" = "chromium.desktop";
        "x-scheme-handler/about" = "chromium.desktop";
        "x-scheme-handler/unknown" = "chromium.desktop";
      };

    };

    configFile = {
      "ghostty".source = ./../../dots/ghostty;
      "sway".source = ./../../dots/sway;
      "i3".source = ./../../dots/i3;
      "helix".source = ./../../dots/helix;
      "rofi".source = ./../../dots/rofi/config;
      "tmux".source = ./../../dots/tmux;
    };

    dataFile = {
      "rofi".source = ./../../dots/rofi/share;
    };
  };

  home.file = {
    ".fehbg".source = ./../../dots/feh/.fehbg;
    ".wallpaper".source = ./../../dots/wallpaper;
  };
}
