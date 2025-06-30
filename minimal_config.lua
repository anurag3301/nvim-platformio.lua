-- insures lazy is installed
local lazypath = vim.loop.os_tmpdir() .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
    {
        "anurag3301/nvim-platformio.lua",
        dependencies = {
            { "akinsho/nvim-toggleterm.lua" },
            { "nvim-telescope/telescope.nvim" },
            { 'nvim-telescope/telescope-ui-select.nvim' },
            { "nvim-lua/plenary.nvim" },
            {'folke/which-key.nvim',
              opts = {
                preset = 'helix', --'modern', --"classic", --
                sort = { 'order', 'group', 'manual', 'mod' },
              },
            },
        },
    },
}

require("lazy").setup(plugins, {
    install = {
        missing = true,
    },
})

vim.opt['number'] = true

require('platformio').setup({
  lsp = 'clangd',
  menu_key = '<leader>p',
})
