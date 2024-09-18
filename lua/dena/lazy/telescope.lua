return {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'BurntSushi/ripgrep'
    },
    config = function()
        local builtin = require('telescope.builtin')
        local find_files = function()
            builtin.find_files {
                find_command = { 'rg', '--files', '--iglob', '!.git', '--hidden' },
                previewer = false
            }
        end
        vim.keymap.set('n', '<leader>pf', find_files, {})
        vim.keymap.set('n', '<leader>ps', function()
            builtin.grep_string({ search = vim.fn.input("Grep > ") });
        end)
        vim.keymap.set('n', '<C-p>', builtin.git_files, {})
    end
}
