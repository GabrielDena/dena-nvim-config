return {
    'puremourning/vimspector',
    config = function ()
        vim.keymap.set('n', '<leader>dd', ':call vimspector#Launch()')
        vim.keymap.set('n', '<leader>de', ':call vimspector#Reset()')
        vim.keymap.set('n', '<leader>dc', ':call vimspector#Continue()')

        vim.keymap.set('n', '<leader>dt', '<Plug>VimspectorToggleBreakpoint')
        vim.keymap.set('n', '<leader>dT', ':call vimspector#ClearBreakpoints()')
        vim.keymap.set('n', '<leader>dn', ':call vimspector#JumpToNextBreakpoint()')

        vim.keymap.set('n', '<leader>dh', ':call vimspector#StepOut()')
        vim.keymap.set('n', '<leader>dj', ':call vimspector#StepInto()')
        vim.keymap.set('n', '<leader>dk', ':call vimspector#Restart')
        vim.keymap.set('n', '<leader>dl', ':call vimspector#StepOver()')
    end
}
