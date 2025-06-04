<h1 align="center">
    nvim-platfromio.lua
</h1>

<p align="center">

<img src="https://github.com/user-attachments/assets/fa3f7663-802e-4845-b4f7-0992e34899f2" style="height: 1em; vertical-align: middle;">
PlatformIO wrapper for Neovim written in Lua.</p>

### Demo

https://github.com/anurag3301/nvim-platformio.lua/assets/52702259/528a2bbf-5a0e-4fa8-87e8-026ce47eef9d

<br>

Try the plugin with this minimal standalone config without making any changes to your current plugin. **Very useful if you facing error while installation or using**
```sh
wget https://raw.githubusercontent.com/anurag3301/nvim-platformio.lua/main/minimal_config.lua
nvim -u minimal_config.lua

# Now run :Pioinit
```

## Installation

#### PlatformIO Core
Check the install instructions on the [PlatformIO docs](https://docs.platformio.org/en/latest/core/installation/index.html)


#### Plugin
Install the plugin using lazy
```lua
return {
   'anurag3301/nvim-platformio.lua',
  -- cmd = { 'Pioinit', 'Piorun', 'Piocmdh', 'Piocmdf', 'Piolib', 'Piomon', 'Piodebug', 'Piodb' },

  -- dependencies are always lazy-loaded unless specified otherwise
  dependencies = {
    { 'akinsho/toggleterm.nvim' },
    { 'nvim-telescope/telescope.nvim' },
    { 'nvim-lua/plenary.nvim' },
    {
      -- WhichKey helps you remember your Neovim keymaps,
      -- by showing available keybindings in a popup as you type.
      'folke/which-key.nvim',
      opts = {
        preset = 'helix', --'modern', --"classic", --
        sort = { 'order', 'group', 'manual', 'mod' },
      },
    },
  },
}
```

#### Usage `:h PlatformIO`

### Configuration
```lua
  require('platformio').setup({
    lsp = 'clangd', --default: ccls, other option: clangd
    -- If you pick clangd, it also creates compile_commands.json
  })

  local ok, wk = pcall(require, 'which-key') --will also load the package if it isn't loaded already
  if not ok then
    vim.api.nvim_echo({
      { 'which-key plugin not found!', 'ErrorMsg' },
    }, true, {})
  else
    local prefix = '<leader>p' -- or use 'gp'
    local Piocmd = 'Piocmdf'   -- 'Piocmdh' (horizontal terminal)  'Piocmdf' (float terminal)
    wk.add({
      { prefix, group = ' PlatformIO:' },
      { prefix .. 'g', group = '  [g]eneral' },
      { prefix .. 'd', group = '  [d]ependencies' },
      { prefix .. 'a', group = '  [a]dvance' },
      { prefix .. 'av', group = '  [v]erbose' },
      { prefix .. 'r', group = '  [r]emote' },
      { prefix .. 'm', group = '  [m]iscellaneous' },
      {
        mode = { 'n' }, -- NORMAL mode
        { prefix .. 'l', '<cmd>' .. 'PioTermList' .. ' <CR>', desc = ' Pio Terminals [l]ist' },
        { prefix .. 'gb', '<cmd>' .. Piocmd .. ' run<CR>', desc = ' [b]uild' },
        { prefix .. 'gc', '<cmd>' .. Piocmd .. ' run -t clean<CR>', desc = ' [c]lean' },
        { prefix .. 'gf', '<cmd>' .. Piocmd .. ' run -t fullclean<CR>', desc = ' [f]ull clean' },
        { prefix .. 'gd', '<cmd>' .. Piocmd .. ' device list<CR>', desc = ' [d]evice list' },
        { prefix .. 'gm', '<cmd>' .. 'Piocmdh' .. ' run -t monitor<CR>', desc = ' [m]onitor' },
        { prefix .. 'gu', '<cmd>' .. Piocmd .. ' run -t upload<CR>', desc = ' [u]pload' },
        { prefix .. 'gs', '<cmd>' .. Piocmd .. ' run -t uploadfs<CR>', desc = ' upload file [s]ystem' },
        { prefix .. 'gt', '<cmd>' .. Piocmd .. '<CR>', desc = ' Core CLI [T]erminal' },

        { prefix .. 'dl', '<cmd>' .. Piocmd .. ' pkg list<CR>', desc = ' [l]ist packages' },
        { prefix .. 'do', '<cmd>' .. Piocmd .. ' pkg outdated<CR>', desc = ' List [o]utdated packages' },
        { prefix .. 'du', '<cmd>' .. Piocmd .. ' pkg update<CR>', desc = ' [u]pdate packages' },

        { prefix .. 'at', '<cmd>' .. Piocmd .. ' test<CR>', desc = ' [t]est' },
        { prefix .. 'ac', '<cmd>' .. Piocmd .. ' check<CR>', desc = ' [c]heck' },
        { prefix .. 'ad', '<cmd>' .. Piocmd .. ' debug<CR>', desc = ' [d]ebug' },
        { prefix .. 'ab', '<cmd>' .. Piocmd .. ' run -t compiledb<CR>', desc = ' compilation data[b]ase' },

        { prefix .. 'av', '<cmd>' .. Piocmd .. ' debug<CR>', desc = ' [v]erbose' },
        { prefix .. 'avb', '<cmd>' .. Piocmd .. ' run -v<CR>', desc = ' [b]uild' },
        { prefix .. 'avd', '<cmd>' .. Piocmd .. ' debug -v<CR>', desc = ' [d]ebug' },
        { prefix .. 'avu', '<cmd>' .. Piocmd .. ' run -v -t upload<CR>', desc = ' [u]pload' },
        { prefix .. 'avs', '<cmd>' .. Piocmd .. ' run -v -t uploadfs<CR>', desc = ' upload file [s]ystem' },
        { prefix .. 'avt', '<cmd>' .. Piocmd .. ' test -v<CR>', desc = ' [t]est' },
        { prefix .. 'avc', '<cmd>' .. Piocmd .. ' check -v<CR>', desc = ' [c]heck' },
        { prefix .. 'ava', '<cmd>' .. Piocmd .. ' run -v -t compiledb<CR>', desc = ' compilation databa[a]e' },

        { prefix .. 'ru', '<cmd>' .. Piocmd .. ' remote run -t upload<CR>', desc = ' [u]pload' },
        { prefix .. 'rt', '<cmd>' .. Piocmd .. ' remote test<CR>', desc = ' [t]est' },
        { prefix .. 'rm', '<cmd>' .. 'Piocmdh' .. ' remote run -t monitor<CR>', desc = ' [m]onitor' },
        { prefix .. 'rd', '<cmd>' .. Piocmd .. ' remote device list<CR>', desc = ' [d]evice list' },

        { prefix .. 'mu', '<cmd>' .. Piocmd .. ' upgrade<CR>', desc = ' [u]pgrade' },
      },
    })
  end
```

### Lazy loading

It's possible to lazy load the plugin using Lazy.nvim, this will load the plugins only when it is needed, to enable lazy loading, add this plugin spec to your config.

```lua
cmd = { 'Pioinit', 'Piorun', 'Piocmdh', 'Piocmdf', 'Piolib', 'Piomon', 'Piodebug', 'Piodb' },
```


### TODO
- Connect Piodebug with DAP