local menu = {
    ["General"] = {
        ["is_open"] = false,
        ['entries'] = {
            ["Build"] = "pio run",
            ["Upload"] = "pio run --verbose --target upload",
            ["Monitor"] = "pio run --target monitor",
            ["Upload and Monitor"] = "pio run --target upload --target monitor",
            ["Clean"] = "pio run --target clean",
            ["Full Clean"] = "platformio run --target fullclean",
            ["Devices"] = "platformio device list",
        }
    },

    ["Dependencies"] = {
        ["is_open"] = false,
        ['entries'] = {
            ["List"] = "pio pkg list",
            ["Outdated"] = "pio pkg outdated",
            ["Update"] = "pio pkg update",
        }
    },

    ["Advanced"] = {
        ["is_open"] = false,
        ['entries'] = {
            ["Test"] = "pio test",
            ["Check"] = "pio check",
            ["Pre-Debug"] = "pio debug",
            ["Verbose Build"] = "pio run --verbose",
            ["Verbose Upload"] = "pio run --verbose --target upload",
            ["Verbose Test"] = "pio test --verbose",
            ["Verbose Check"] = "pio check --verbose",
            ["Compilation Database"] = "pio run --target compiledb",
        }
    },

    ["Remote"] = {
        ["is_open"] = false,
        ['entries'] = {
            ["Remote Upload"] = "pio remote run --target upload",
            ["Remote Test"] = "pio remote test",
            ["Remote Monitor"] = "pio remote device monitor",
            ["Remote Devices"] = "pio remote device list",
        }
    },

    ["Miscellaneous"] = {
        ["is_open"] = false,
        ['entries'] = {
            ["Upgrade PlatformIO Core"] = "pio upgrade",
        }
    },
}

return menu
