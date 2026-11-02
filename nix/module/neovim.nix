{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
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
      wl-clipboard
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
        plugin = which-key-nvim;
        type = "lua";
        config = ''
          require('which-key').setup{}
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
          require('which-key').add({
            { '<leader>f', group = 'find' },
            { '<leader>ff', desc = 'find files' },
            { '<leader>fg', desc = 'live grep' },
            { '<leader>fb', desc = 'buffers' },
          })
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

          require('which-key').add({
            { '<leader>e', desc = 'harpoon add' },
            { '<leader>h', desc = 'harpoon menu' },
            { '<leader>1', desc = 'harpoon 1' },
            { '<leader>2', desc = 'harpoon 2' },
            { '<leader>3', desc = 'harpoon 3' },
            { '<leader>4', desc = 'harpoon 4' },
          })
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

              vim.api.nvim_create_autocmd('BufWritePre', {
                buffer = args.buf,
                callback = function()
                  vim.lsp.buf.format({ bufnr = args.buf, id = args.data.client_id })
                end,
              })

              require('which-key').add({
                { '<leader>k', desc = 'hover' },
                { '<leader>a', desc = 'code action' },
                { '<leader>r', desc = 'rename' },
                { '<leader>d', desc = 'diagnostics' },
                { '<leader>s', desc = 'document symbols' },
                { '<leader>S', desc = 'workspace symbols' },
              })
            end,
          })
        '';
      }
      nvim-web-devicons
      {
        plugin = nvim-autopairs;
        type = "lua";
        config = ''
          require('nvim-autopairs').setup{}
        '';
      }
      {
        plugin = gitsigns-nvim;
        type = "lua";
        config = ''
          require('gitsigns').setup()
        '';
      }
      {
        plugin = minuet-ai-nvim;
        type = "lua";
        config = ''
          require('minuet').setup {
            provider = 'openai_fim_compatible',
            n_completions = 1,
            context_window = 2048,
            virtualtext = {
              auto_trigger_ft = {},
              keymap = {
                accept = '<A-A>',
                accept_line = '<A-a>',
                accept_n_lines = '<A-z>',
                prev = '<A-[>',
                next = '<A-]>',
                dismiss = '<A-e>',
              },
            },
            provider_options = {
              openai_fim_compatible = {
                api_key = 'TERM',
                name = 'Ollama',
                end_point = 'http://albatross:11434/v1/completions',
                model = 'qwen2.5-coder:7b',
                optional = {
                  max_tokens = 56,
                  top_p = 0.9,
                },
              },
            },
          }

          vim.keymap.set('i', '<A-/>', require('minuet.virtualtext').action.next, {
            desc = 'minuet: suggest now',
          })

          require('which-key').add({
            { '<A-/>', desc = 'minuet: suggest now', mode = 'i' },
            { '<A-A>', desc = 'minuet: accept full suggestion', mode = 'i' },
            { '<A-a>', desc = 'minuet: accept one line', mode = 'i' },
            { '<A-z>', desc = 'minuet: accept n lines', mode = 'i' },
            { '<A-[>', desc = 'minuet: prev suggestion', mode = 'i' },
            { '<A-]>', desc = 'minuet: next suggestion', mode = 'i' },
            { '<A-e>', desc = 'minuet: dismiss suggestion', mode = 'i' },
          })
        '';
      }
      {
        plugin = blink-cmp;
        type = "lua";
        config = ''
          require('blink.cmp').setup({
            keymap = { preset = 'super-tab' },
            appearance = { nerd_font_variant = 'mono' },
            sources = { default = { 'lsp', 'path', 'buffer' } },
          })

          require('which-key').add({
            { '<Tab>', desc = 'blink: accept / snippet forward', mode = 'i' },
            { '<S-Tab>', desc = 'blink: snippet backward', mode = 'i' },
            { '<C-space>', desc = 'blink: show / toggle docs', mode = 'i' },
            { '<C-e>', desc = 'blink: cancel', mode = 'i' },
            { '<C-n>', desc = 'blink: select next', mode = 'i' },
            { '<C-p>', desc = 'blink: select prev', mode = 'i' },
            { '<C-k>', desc = 'blink: show/hide signature', mode = 'i' },
          })
        '';
      }
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
      vim.opt.clipboard = 'unnamedplus'
      vim.opt.mouse = ""
    '';
  };
}
