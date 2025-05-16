local entries = {
    {
        title = "General",
        is_open = true,
        entries = {
            { title = "Build", command = "pio run" },
            { title = "Upload", command = "pio run --verbose --target upload" },
            { title = "Monitor", command = "pio run --target monitor" },
            { title = "Upload and Monitor", command = "pio run --target upload --target monitor" },
            { title = "Clean", command = "pio run --target clean" },
            { title = "Full Clean", command = "platformio run --target fullclean" },
            { title = "Devices", command = "platformio device list" },
        },
    },
    {
        title = "Dependencies",
        is_open = false,
        entries = {
            { title = "List", command = "pio pkg list" },
            { title = "Outdated", command = "pio pkg outdated" },
            { title = "Update", command = "pio pkg update" },
        },
    },
    {
        title = "Advanced",
        is_open = false,
        entries = {
            { title = "Test", command = "pio test" },
            { title = "Check", command = "pio check" },
            { title = "Pre-Debug", command = "pio debug" },
            { title = "Verbose Build", command = "pio run --verbose" },
            { title = "Verbose Upload", command = "pio run --verbose --target upload" },
            { title = "Verbose Test", command = "pio test --verbose" },
            { title = "Verbose Check", command = "pio check --verbose" },
            { title = "Compilation Database", command = "pio run --target compiledb" },
        },
    },
    {
        title = "Remote",
        is_open = false,
        entries = {
            { title = "Remote Upload", command = "pio remote run --target upload" },
            { title = "Remote Test", command = "pio remote test" },
            { title = "Remote Monitor", command = "pio remote device monitor" },
            { title = "Remote Devices", command = "pio remote device list" },
        },
    },
    {
        title = "Miscellaneous",
        is_open = false,
        entries = {
            { title = "Upgrade PlatformIO Core", command = "pio upgrade" },
        },
    },
}


return entries
