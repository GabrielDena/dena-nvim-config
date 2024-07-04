return {
    'puremourning/vimspector',
    config = function ()
        vim.keymap.set('n', '<leader>dd', ':call vimspector#Launch()')
        vim.keymap.set('n', '<leader>de', ':call vimspector#Reset()')
        vim.keymap.set('n', '<leader>dc', ':call vimspector#Continue()')

        vim.keymap.set('n', '<leader>dt', '<Plug>VimspectorToggleBreakpoint')
        vim.keymap.set('n', '<leader>dT', ':call vimspector#ClearBreakpoints()')
        vim.keymap.set('n', '<leader>dn', ':call vimspector#JumpToNextBreakpoint()')

        vim.keymap.set('n', '<leader>dh', '<Plug>VimspectorStepOut')
        vim.keymap.set('n', '<leader>dj', '<Plug>VimspectorStepInto')
        vim.keymap.set('n', '<leader>dk', '<Plug>VimspectorRestart')
        vim.keymap.set('n', '<leader>dl', '<Plug>VimspectorStepOver')
    end
}
