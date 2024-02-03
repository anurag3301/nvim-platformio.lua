# nvim-platfromio.lua
PlatformIO wrapper for neovim written in lua

## The plugin is under development
### Please read the [Docs](https://github.com/anurag3301/nvim-platformio.lua/blob/main/doc/platformio.txt) to know about rest of commands.
### Installation
Install PlatformIO using pip

```sh
python3 -c "$(curl -fsSL https://raw.githubusercontent.com/platformio/platformio/master/scripts/get-platformio.py)"

# Check if you have a working Installation of PlatformIO
pio --version
```

Install the plugin using packer

```lua
use {
    'anurag3301/nvim-platformio.lua',
    rocks = {'luasec'},
    requires = {
        {'akinsho/nvim-toggleterm.lua'},
        {'nvim-telescope/telescope.nvim'},
        {'nvim-lua/plenary.nvim'},
    }
}
```

### Usage
Create a new directory for the project and cd into it
```sh
mkdir project
cd project
```
Run neovim and run command `:Pioinit`

Search and chose the required board from the Telescope picker, now select the required framework

Now you have the project configured




https://github.com/anurag3301/nvim-platformio.lua/assets/52702259/528a2bbf-5a0e-4fa8-87e8-026ce47eef9d





### More stuff comming soon
