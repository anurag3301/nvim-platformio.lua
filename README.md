# nvim-platfromio.lua

PlatformIO wrapper for neovim written in lua.

### Installation

Install PlatformIO using pip

```sh
curl -fsSL -o get-platformio.py https://raw.githubusercontent.com/platformio/platformio-core-installer/master/get-platformio.py
python3 get-platformio.py

# Check if you have a working Installation of PlatformIO
pio --version
```

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

Or install the plugin using lazy

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

### Lazy loading

It's possible to lazy load the plugin using Lazy.nvim, this will load the plugins only when it is needed.

to enable lazy loading, add this plugin spec to your config.

```lua
cmd = {
    "Pioinit",
    "Piorun",
    "Piocmd",
    "Piolib",
    "Piomon",
    "Piodebug",
},
```

### Demo

https://github.com/anurag3301/nvim-platformio.lua/assets/52702259/528a2bbf-5a0e-4fa8-87e8-026ce47eef9d

### TODO

- Syntax Highlighted Json Preview
