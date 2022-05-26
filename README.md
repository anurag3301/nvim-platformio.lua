# nvim-platfromio.lua
PlatformIO wrapper for neovim written in lua

## The plugin is under development

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
    rocks = {'lunajson'},
    requires = {{'akinsho/nvim-toggleterm.lua', opt = true}}
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

### More stuff comming soon
