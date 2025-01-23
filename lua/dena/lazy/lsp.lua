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
    local cmp = require('cmp')
    local cmp_lsp = require('cmp_nvim_lsp')
    local capabilities = vim.tbl_deep_extend(
      'force',
      {},
      vim.lsp.protocol.make_client_capabilities(),
      cmp_lsp.default_capabilities())
    local function organize_imports()
      local params = {
        command = "_typescript.organizeImports",
        arguments = { vim.api.nvim_buf_get_name(0) },
        title = ""
      }
      vim.lsp.buf.execute_command(params)
    end

    require('fidget').setup({})
    require('mason').setup()
    require('mason-lspconfig').setup({
      ensure_installed = {
        'angularls',
        'dockerls',
        'docker_compose_language_service',
        'eslint',
        'ts_ls',    --Darwin
        'tsserver', --Linux
        'lua_ls',
        'terraformls',
        'vimls',
        'spectral'
      },
      handlers = {
        function(server_name) -- default handler (optional)
          require('lspconfig')[server_name].setup {
            capabilities = capabilities
          }
        end,

        zls = function()
          local lspconfig = require('lspconfig')
          lspconfig.zls.setup({
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
        ['lua_ls'] = function()
          local lspconfig = require('lspconfig')
          lspconfig.lua_ls.setup {
            capabilities = capabilities,
            settings = {
              Lua = {
                runtime = { version = 'Lua 5.1' },
                diagnostics = {
                  globals = { 'bit', 'vim', 'it', 'describe', 'before_each', 'after_each' },
                }
              }
            }
          }
        end,
        ['spectral'] = function()
          local lspconfig = require('lspconfig')
          lspconfig.jsonls.setup {
            filetypes = { 'json', 'jsonc' },
            settings = {
              json = {
                -- Schemas https://www.schemastore.org
                schemas = {
                  {
                    fileMatch = { 'package.json' },
                    url = 'https://json.schemastore.org/package.json'
                  },
                  {
                    fileMatch = { 'tsconfig*.json' },
                    url = 'https://json.schemastore.org/tsconfig.json'
                  },
                  {
                    fileMatch = {
                      '.prettierrc',
                      '.prettierrc.json',
                      'prettier.config.json'
                    },
                    url = 'https://json.schemastore.org/prettierrc.json'
                  },
                  {
                    fileMatch = { '.eslintrc', '.eslintrc.json' },
                    url = 'https://json.schemastore.org/eslintrc.json'
                  },
                  {
                    fileMatch = { '.babelrc', '.babelrc.json', 'babel.config.json' },
                    url = 'https://json.schemastore.org/babelrc.json'
                  },
                  {
                    fileMatch = { 'lerna.json' },
                    url = 'https://json.schemastore.org/lerna.json'
                  },
                  {
                    fileMatch = { 'now.json', 'vercel.json' },
                    url = 'https://json.schemastore.org/now.json'
                  },
                  {
                    fileMatch = {
                      '.stylelintrc',
                      '.stylelintrc.json',
                      'stylelint.config.json'
                    },
                    url = 'http://json.schemastore.org/stylelintrc.json'
                  }
                }
              }
            }
          }
        end,
        ['ts_ls'] = function()
          local lspconfig = require('lspconfig')
          local tsCapabilities = capabilities
          tsCapabilities.textDocument.formatting = false
          tsCapabilities.textDocument.rangeFormatting = false
          lspconfig.ts_ls.setup {
            on_attach = on_attach,
            capabilities = tsCapabilities,
            commands = {
              OrganizeImports = {
                organize_imports,
                description = "Organize Imports"
              }
            }
          }
        end,
        ['tsserver'] = function()
          local lspconfig = require('lspconfig')
          local tsCapabilities = capabilities
          tsCapabilities.textDocument.formatting = false
          tsCapabilities.textDocument.rangeFormatting = false
          lspconfig.ts_ls.setup {
            on_attach = on_attach,
            capabilities = tsCapabilities,
            commands = {
              OrganizeImports = {
                organize_imports,
                description = "Organize Imports"
              }
            }
          }
        end,
        ['terraformls'] = function()
          local lspconfig = require('lspconfig')
          lspconfig.terraformls.setup {}
          vim.api.nvim_create_autocmd({ "BufWritePre" }, {
            pattern = { "*.tf", "*.tfvars" },
            callback = function()
              vim.lsp.buf.format()
            end,
          })
        end
      }
    })

    local cmp_select = { behavior = cmp.SelectBehavior.Select }

    cmp.setup({
      snippet = {
        expand = function(args)
          require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
        ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
        ['<C-y>'] = cmp.mapping.confirm({ select = true }),
        ['<C-Space>'] = cmp.mapping.complete(),
      }),
      sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' }, -- For luasnip users.
      }, {
        { name = 'buffer' },
      })
    })

    vim.diagnostic.config({
      -- update_in_insert = true,
      float = {
        focusable = false,
        style = 'minimal',
        border = 'rounded',
        source = 'always',
        header = '',
        prefix = '',
      },
    })
  end;

  vim.keymap.set('n', '<C-g>', vim.lsp.buf.definition, { noremap = true, silent = true})

  vim.keymap.set('n', '<leader>i', function()
        local params = {
            context = { only = { 'source.addMissingImports' } },
        }
        vim.lsp.buf.code_action(params)
    end, { noremap = true, silent = true, desc = 'Add missing imports' }),
}
