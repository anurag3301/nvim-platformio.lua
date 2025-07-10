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
    { 'nvim-telescope/telescope-ui-select.nvim' },
    { 'nvim-lua/plenary.nvim' },

    -- which-key is optional dependency, if you wish not to have piomenu, you can remove it
    {'folke/which-key.nvim',
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

    -- Comment out following line if you want to disable the piomenu.
    menu_key = '<leader>p',
  })

```

### Following are the default keybindings, you can overwrite them in the config
```lua
require('platformio').setup({

  menu_bindings = {
    { group = '  [g]eneral', key = 'g', elements = {
      { key = 'b', cmd = 'run', desc = ' [b]uild' },
      { key = 'c', cmd = 'run -t clean', desc = ' [c]lean' },
      { key = 'f', cmd = 'run -t fullclean', desc = ' [f]ull clean' },
      { key = 'd', cmd = 'device list', desc = ' [d]evice list' },
      { key = 'm', cmd = 'run -t monitor', desc = ' [m]onitor' },
      { key = 'u', cmd = 'run -t upload', desc = ' [u]pload' },
      { key = 's', cmd = 'run -t uploadfs', desc = ' upload file [s]ystem' },
      { key = 't', cmd = '', desc = ' Core CLI [T]erminal' },
    }},
    { group = '  [d]ependencies', key = 'd', elements = {
      { key = 'l', cmd = 'pkg list', desc = ' [l]ist packages' },
      { key = 'o', cmd = 'pkg outdated', desc = ' List [o]utdated packages' },
      { key = 'u', cmd = 'pkg update', desc = ' [u]pdate packages' },
    }},
    { group = '  [a]dvance', key = 'a', elements = {
      { key = 't', cmd = 'test', desc = ' [t]est' },
      { key = 'c', cmd = 'check', desc = ' [c]heck' },
      { key = 'd', cmd = 'debug', desc = ' [d]ebug' },
      { key = 'b', cmd = 'run -t compiledb', desc = ' compilation data[b]ase' },
    }},
    { group = '  [v]erbose', key = 'av', elements = {
      { key = 'v', cmd = 'debug', desc = ' [v]erbose' },
      { key = 'b', cmd = 'run -v', desc = ' [b]uild' },
      { key = 'd', cmd = 'debug -v', desc = ' [d]ebug' },
      { key = 'u', cmd = 'run -v -t upload', desc = ' [u]pload' },
      { key = 's', cmd = 'run -v -t uploadfs', desc = ' upload file [s]ystem' },
      { key = 't', cmd = 'test -v', desc = ' [t]est' },
      { key = 'c', cmd = 'check -v', desc = ' [c]heck' },
      { key = 'a', cmd = 'run -v -t compiledb', desc = ' compilation databa[a]e' },
    }},
    { group = '  [r]emote', key = 'r', elements = {
      { key = 'u', cmd = 'remote run -t upload', desc = ' [u]pload' },
      { key = 't', cmd = 'remote test', desc = ' [t]est' },
      { key = 'm', cmd = 'remote run -t monitor', desc = ' [m]onitor' },
      { key = 'd', cmd = 'remote device list', desc = ' [d]evice list' },
    }},
    { group = '  [m]iscellaneous', key = 'm', elements = {
      { key = 'u', cmd = 'upgrade', desc = ' [u]pgrade' },
    }},
  }

}
```

### Lazy loading

It's possible to lazy load the plugin using Lazy.nvim, this will load the plugins only when it is needed, to enable lazy loading, add this plugin spec to your config.

```lua
cmd = { 'Pioinit', 'Piorun', 'Piocmdh', 'Piocmdf', 'Piolib', 'Piomon', 'Piodebug', 'Piodb' },
```


### TODO
- Connect Piodebug with DAP
