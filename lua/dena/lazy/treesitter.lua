return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  lazy = false,
  config = function()
    require('nvim-treesitter').setup({
      ensure_installed = { "javascript", "typescript", "angular", "dockerfile",
        "terraform", "go", "elixir", "dart", "c", "lua",
        "vim", "vimdoc", "query" },
      auto_install = true,
      highlight = { enable = true },
    })
  end
}
