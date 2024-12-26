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
Install the plugin using packer
```lua
use {
    'anurag3301/nvim-platformio.lua',
    requires = {
        {'akinsho/nvim-toggleterm.lua'},
        {'nvim-telescope/telescope.nvim'},
        {'nvim-lua/plenary.nvim'},
    }
}
```
Or Install the plugin using lazy
```lua
return {
    "anurag3301/nvim-platformio.lua",
    dependencies = {
        { "akinsho/nvim-toggleterm.lua" },
        { "nvim-telescope/telescope.nvim" },
        { "nvim-lua/plenary.nvim" },
    },
}
```

#### Usage `:h PlatformIO`

### Configuration
```lua
require('platformio').setup({
    lsp = "ccls" --default: ccls, other option: clangd
                 -- If you pick clangd, it also creates compile_commands.json
})
```

### Lazy loading

It's possible to lazy load the plugin using Lazy.nvim, this will load the plugins only when it is needed, to enable lazy loading, add this plugin spec to your config.

```lua
cmd = {
    "Pioinit",
    "Piorun",
    "Piocmd",
    "Piolib",
    "Piomon",
    "Piodebug",
    "Piodb",
},
```


### TODO
- Connect Piodebug with DAP
