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

  -- to use cond; first time you create project folder, you should create empty platformio.ini file
  cond = function() -- start/load nvim-platformio when platformio.ini file exist in cwd
    return vim.fn.filereadable('platformio.ini') == 1
  end,

  -- dependencies are always lazy-loaded unless specified otherwise
  dependencies = {
    { 'akinsho/toggleterm.nvim' },
    { 'nvim-telescope/telescope.nvim' },
    { 'nvim-telescope/telescope-ui-select.nvim' },
    { 'nvim-lua/plenary.nvim' },
    { 'folke/which-key.nvim' },
  },
}
```

#### Usage `:h PlatformIO`

### Configuration
```lua
    local pok, platformio = pcall(require, 'platformio')
    if pok then
      platformio.setup({
        lsp = 'clangd',
        menu_key = '<leader>\\', -- replace this menu key  to your convenience
      })
    end
```

### Below is the default configuration you can mdoify as needed.
```lua
    local pok, platformio = pcall(require, 'platformio')
    if pok then
      platformio.setup({
        lsp = 'ccls', --default: ccls, other option: clangd
        -- If you pick clangd, it also creates compile_commands.json

        -- Uncomment out following line to enable platformio menu.
        -- menu_key = '<leader>\\', -- replace this menu key  to your convenience
        menu_name = 'PlatformIO', -- replace this menu name to your convenience

        -- Following are the default keybindings, you can overwrite them in the config
        menu_bindings = {
          { node = 'item', desc = '[L]ist terminals',    shortcut = 'l', command = 'PioTermList' },
          { node = 'item', desc = '[T]erminal Core CLI', shortcut = 't', command = 'Piocmdf' },
          {
            node = 'menu',
            desc = '[G]eneral',
            shortcut = 'g',
            items = {
              { node = 'item', desc = '[B]uild',       shortcut = 'b', command = 'Piocmdf run' },
              { node = 'item', desc = '[U]pload',      shortcut = 'u', command = 'Piocmdf run -t upload' },
              { node = 'item', desc = '[M]onitor',     shortcut = 'm', command = 'Piocmdh run -t monitor' },
              { node = 'item', desc = '[C]lean',       shortcut = 'c', command = 'Piocmdf run -t clean' },
              { node = 'item', desc = '[F]ull clean',  shortcut = 'f', command = 'Piocmdf run -t fullclean' },
              { node = 'item', desc = '[D]evice list', shortcut = 'd', command = 'Piocmdf device list' },
            },
          },
          {
            node = 'menu',
            desc = '[P]latform',
            shortcut = 'p',
            items = {
              { node = 'item', desc = '[B]uild file system',  shortcut = 'b', command = 'Piocmdf run -t buildfs' },
              { node = 'item', desc = 'Program [S]ize',       shortcut = 's', command = 'Piocmdf run -t size' },
              { node = 'item', desc = '[U]pload file system', shortcut = 'u', command = 'Piocmdf run -t uploadfs' },
              { node = 'item', desc = '[E]rase Flash',        shortcut = 'e', command = 'Piocmdf run -t erase' },
            },
          },
          {
            node = 'menu',
            desc = '[D]ependencies',
            shortcut = 'd',
            items = {
              { node = 'item', desc = '[L]ist packages',     shortcut = 'l', command = 'Piocmdf pkg list' },
              { node = 'item', desc = '[O]utdated packages', shortcut = 'o', command = 'Piocmdf pkg outdated' },
              { node = 'item', desc = '[U]pdate packages',   shortcut = 'u', command = 'Piocmdf pkg update' },
            },
          },
          {
            node = 'menu',
            desc = '[A]dvanced',
            shortcut = 'a',
            items = {
              { node = 'item', desc = '[T]est',                 shortcut = 't', command = 'Piocmdf test' },
              { node = 'item', desc = '[C]heck',                shortcut = 'c', command = 'Piocmdf check' },
              { node = 'item', desc = '[D]ebug',                shortcut = 'd', command = 'Piocmdf debug' },
              { node = 'item', desc = 'Compilation Data[b]ase', shortcut = 'b', command = 'Piocmdf run -t compiledb' },
              {
                node = 'menu',
                desc = '[V]erbose',
                shortcut = 'v',
                items = {
                  { node = 'item', desc = 'Verbose [B]uild',  shortcut = 'b', command = 'Piocmdf run -v' },
                  { node = 'item', desc = 'Verbose [U]pload', shortcut = 'u', command = 'Piocmdf run -v -t upload' },
                  { node = 'item', desc = 'Verbose [T]est',   shortcut = 't', command = 'Piocmdf test -v' },
                  { node = 'item', desc = 'Verbose [C]heck',  shortcut = 'c', command = 'Piocmdf check -v' },
                  { node = 'item', desc = 'Verbose [D]ebug',  shortcut = 'd', command = 'Piocmdf debug -v' },
                },
              },
            },
          },
          {
            node = 'menu',
            desc = '[R]emote',
            shortcut = 'r',
            items = {
              { node = 'item', desc = 'Remote [U]pload',  shortcut = 'u', command = 'Piocmdf remote run -t upload' },
              { node = 'item', desc = 'Remote [T]est',    shortcut = 't', command = 'Piocmdf remote test' },
              { node = 'item', desc = 'Remote [M]onitor', shortcut = 'm', command = 'Piocmdh remote run -t monitor' },
              { node = 'item', desc = 'Remote [D]evices', shortcut = 'd', command = 'Piocmdf remote device list' },
            },
          },
          {
            node = 'menu',
            desc = '[M]iscellaneous',
            shortcut = 'm',
            items = {
              { node = 'item', desc = '[U]pgrade PlatformIO Core', shortcut = 'u', command = 'Piocmdf upgrade' },
            },
          },
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
