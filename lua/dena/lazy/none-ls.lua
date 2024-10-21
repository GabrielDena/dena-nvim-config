return {
    'nvimtools/none-ls.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
        local null_ls = require('null-ls')
        local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

        null_ls.setup({
            sources = {
                null_ls.builtins.formatting.prettier.with({
                    filetypes = {
                        "javascript",
                        "typescript",
                        "css",
                        "scss",
                        "html",
                        "json",
                        "yaml",
                        "markdown",
                        "graphql",
                        "md",
                        "txt",
                    },
                    only_local = "node_modules/.bin",
                    extra_args = { "--print-width", "120" }
                }),
                null_ls.builtins.formatting.stylua.with({
                    filetypes = {
                        "lua",
                    },
                    args = { "--indent-width", "2", "--indent-type", "Spaces", "-" },
                }),
                null_ls.builtins.diagnostics.stylelint.with({
                    filetypes = {
                        "css",
                        "scss",
                    },
                }),
            },

            on_attach = function(client, bufnr)
                if client.supports_method('textDocument/formatting') then
                    local filetype = vim.bo[bufnr].filetype
                    if filetype ~= "html" then
                        vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
                        vim.api.nvim_create_autocmd('BufWritePre', {
                            group = augroup,
                            buffer = bufnr,
                            callback = function()
                                vim.lsp.buf.format({ bufnr = bufnr })
                            end,
                        })
                    end
                end
            end,
        })
    end
}
