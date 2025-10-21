-- insures lazy is installed
local lazypath = vim.loop.os_tmpdir() .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
  {
    'anurag3301/nvim-platformio.lua',
    -- cmd = { 'Pioinit', 'Piorun', 'Piocmdh', 'Piocmdf', 'Piolib', 'Piomon', 'Piodebug', 'Piodb' },

    -- optional: cond used to enable/disable platformio
    -- based on existance of platformio.ini file and .pio folder in cwd.
    -- You can enable platformio plugin, using :Pioinit command
    cond = function()
      -- local platformioRootDir = vim.fs.root(vim.fn.getcwd(), { 'platformio.ini' }) -- cwd and parents
      local platformioRootDir = (vim.fn.filereadable('platformio.ini') == 1) and vim.fn.getcwd() or nil
      if platformioRootDir and vim.fs.find('.pio', { path = platformioRootDir, type = 'directory' })[1] then
        -- if platformio.ini file and .pio folder exist in cwd, enable plugin to install plugin (if not istalled) and load it.
        vim.g.platformioRootDir = platformioRootDir
      elseif (vim.uv or vim.loop).fs_stat(vim.fn.stdpath('data') .. '/lazy/nvim-platformio.lua') == nil then
        -- if nvim-platformio not installed, enable plugin to install it first time
        vim.g.platformioRootDir = vim.fn.getcwd()
      else -- if nvim-platformio.lua installed but disabled, create Pioinit command
        vim.api.nvim_create_user_command('Pioinit', function() --available only if no platformio.ini and .pio in cwd
          vim.api.nvim_create_autocmd('User', {
            pattern = { 'LazyRestore', 'LazyLoad' },
            once = true,
            callback = function(args)
              if args.match == 'LazyRestore' then
                require('lazy').load({ plugins = { 'nvim-platformio.lua' } })
              elseif args.match == 'LazyLoad' then
                vim.notify('PlatformIO loaded', vim.log.levels.INFO, { title = 'PlatformIO' })
                vim.cmd('Pioinit')
              end
            end,
          })
          vim.g.platformioRootDir = vim.fn.getcwd()
          require('lazy').restore({ plguins = { 'nvim-platformio.lua' }, show = false })
        end, {})
      end
      return vim.g.platformioRootDir ~= nil
    end,

    -- Dependencies are lazy-loaded by default unless specified otherwise.
    dependencies = {
      { 'akinsho/toggleterm.nvim' },
      { 'nvim-telescope/telescope.nvim' },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-lua/plenary.nvim' },
      { 'folke/which-key.nvim' },
    },
  },
}

require('lazy').setup(plugins, {
  install = {
    missing = true,
  },
})

vim.opt['number'] = true

local pok, platformio = pcall(require, 'platformio')
if pok then
  platformio.setup({
    lsp = 'clangd',
    menu_key = '<leader>\\', -- replace this menu key  to your convenience
  })
end
