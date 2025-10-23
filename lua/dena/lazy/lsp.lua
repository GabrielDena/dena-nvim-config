return {
  'neovim/nvim-lspconfig',
  dependencies = {
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-cmdline',
    'hrsh7th/nvim-cmp',
    'L3MON4D3/LuaSnip',
    'saadparwaiz1/cmp_luasnip',
    'j-hui/fidget.nvim',
  },
  config = function()
    local lspconfig = require('lspconfig')
    local cmp = require('cmp')
    local cmp_lsp = require('cmp_nvim_lsp')

    -- Capabilities para nvim-cmp
    local capabilities = vim.tbl_deep_extend(
      'force',
      {},
      vim.lsp.protocol.make_client_capabilities(),
      cmp_lsp.default_capabilities()
    )

    -- Organize imports (TS)
    local function organize_imports()
      local params = {
        command = "_typescript.organizeImports",
        arguments = { vim.api.nvim_buf_get_name(0) },
        title = ""
      }
      vim.lsp.buf.execute_command(params)
    end

    -- on_attach comum: keymaps e ajustes por server
    local on_attach = function(client, bufnr)
      local bufmap = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, buffer = bufnr, desc = desc })
      end

      -- seus keymaps
      bufmap('n', '<C-g>', vim.lsp.buf.definition, 'Go to definition')
      bufmap('n', '<leader>i', function()
        vim.lsp.buf.code_action({ context = { only = { 'source.addMissingImports' } } })
      end, 'Add missing imports')

      -- Desabilitar formatting de servers que conflitam com formatters externos
      local name = client.name
      if name == 'tsserver' or name == 'ts_ls' or name == 'eslint' then
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
      end
    end

    require('fidget').setup({})
    require('mason').setup()

    require('mason-lspconfig').setup({
      ensure_installed = {
        'angularls',
        'dockerls',
        'docker_compose_language_service',
        'eslint',
        'ts_ls',      -- Typescript (moderno)
        -- 'tsserver', -- (alternativa antiga, se preferir)
        'lua_ls',
        'terraformls',
        'vimls',
        'jsonls',
        'zls',
      },
      handlers = {
        -- Handler default
        function(server_name)
          lspconfig[server_name].setup({
            capabilities = capabilities,
            on_attach = on_attach,
          })
        end,

        -- Zig
        zls = function()
          lspconfig.zls.setup({
            capabilities = capabilities,
            on_attach = on_attach,
            root_dir = lspconfig.util.root_pattern('.git', 'build.zig', 'zls.json'),
            settings = {
              zls = {
                enable_inlay_hints = true,
                enable_snippets = true,
                warn_style = true,
              },
            },
          })
          vim.g.zig_fmt_parse_errors = 0
          vim.g.zig_fmt_autosave = 0
        end,

        -- Lua
        ['lua_ls'] = function()
          lspconfig.lua_ls.setup({
            capabilities = capabilities,
            on_attach = on_attach,
            settings = {
              Lua = {
                runtime = { version = 'Lua 5.1' },
                diagnostics = {
                  globals = { 'bit', 'vim', 'it', 'describe', 'before_each', 'after_each' },
                },
                workspace = { checkThirdParty = false },
                telemetry = { enable = false },
              }
            }
          })
        end,

        -- JSON com schemas do SchemaStore
        ['jsonls'] = function()
          lspconfig.jsonls.setup({
            capabilities = capabilities,
            on_attach = on_attach,
            settings = {
              json = {
                schemas = {
                  { fileMatch = { 'package.json' }, url = 'https://json.schemastore.org/package.json' },
                  { fileMatch = { 'tsconfig*.json' }, url = 'https://json.schemastore.org/tsconfig.json' },
                  { fileMatch = { '.prettierrc', '.prettierrc.json', 'prettier.config.json' }, url = 'https://json.schemastore.org/prettierrc.json' },
                  { fileMatch = { '.eslintrc', '.eslintrc.json' }, url = 'https://json.schemastore.org/eslintrc.json' },
                  { fileMatch = { '.babelrc', '.babelrc.json', 'babel.config.json' }, url = 'https://json.schemastore.org/babelrc.json' },
                  { fileMatch = { 'lerna.json' }, url = 'https://json.schemastore.org/lerna.json' },
                  { fileMatch = { 'now.json', 'vercel.json' }, url = 'https://json.schemastore.org/now.json' },
                  { fileMatch = { '.stylelintrc', '.stylelintrc.json', 'stylelint.config.json' }, url = 'https://json.schemastore.org/stylelintrc.json' },
                },
                validate = { enable = true },
              }
            }
          })
        end,

        -- TypeScript (ts_ls moderno)
        ['ts_ls'] = function()
          lspconfig.ts_ls.setup({
            capabilities = capabilities,
            on_attach = on_attach,
            commands = {
              OrganizeImports = {
                organize_imports,
                description = "Organize Imports"
              }
            }
          })
        end,

        -- Se quiser usar o tsserver antigo (descomente no ensure_installed também)
        -- ['tsserver'] = function()
        --   lspconfig.tsserver.setup({
        --     capabilities = capabilities,
        --     on_attach = on_attach,
        --     commands = {
        --       OrganizeImports = {
        --         organize_imports,
        --         description = "Organize Imports"
        --       }
        --     }
        --   })
        -- end,

        -- Terraform (format on save)
        ['terraformls'] = function()
          lspconfig.terraformls.setup({
            capabilities = capabilities,
            on_attach = on_attach,
          })
          vim.api.nvim_create_autocmd({ "BufWritePre" }, {
            pattern = { "*.tf", "*.tfvars" },
            callback = function()
              vim.lsp.buf.format({ async = false })
            end,
          })
        end,
      }
    })

    -- nvim-cmp
    local cmp_select = { behavior = cmp.SelectBehavior.Select }
    cmp.setup({
      snippet = {
        expand = function(args) require('luasnip').lsp_expand(args.body) end,
      },
      mapping = cmp.mapping.preset.insert({
        ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
        ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
        ['<C-y>'] = cmp.mapping.confirm({ select = true }),
        ['<C-Space>'] = cmp.mapping.complete(),
      }),
      sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
      }, {
        { name = 'buffer' },
      })
    })

    -- Diagnostics UI
    vim.diagnostic.config({
      float = {
        focusable = false,
        style = 'minimal',
        border = 'rounded',
        source = 'always',
        header = '',
        prefix = '',
      },
    })
  end,
}

