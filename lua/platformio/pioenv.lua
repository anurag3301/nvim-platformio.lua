local utils = require('platformio.utils')
local M = {}

function M.pioenv()
    --- @type vim.log.levels
    local loglevel = vim.log.levels.INFO
    if not utils.pio_install_check() then
        return
    end
    utils.cd_pioini()

    -- TODO: execute target list command
    local cmd = 'pio run --list-targets'
    --- @type file*?
    local stdio_stream
    stdio_stream, _ = io.popen(cmd, 'r')
    -- TODO: error checking
    if not stdio_stream then
        vim.notify('opening stdio or executing the cmd ' .. cmd .. 'failed', vim.log.levels.ERROR)
        return
    end

    io.input(stdio_stream)
    -- vim.notify(io.read('*a'), vim.log.levels.INFO)

    -- table layout:
    -- table header
    -- ----------------------
    -- env_name_without_spaces      some garbage
    --
    -- env_name_without_spaces      some garbage
    -- ...

    -- discard the first few lines, since they are just table headers and decorators
    -- _ = stdio_stream.read(stdio_stream, '*l')
    -- _ = stdio_stream.read(stdio_stream, '*l')

    --- @type string[]
    local table_lines = {}
    --- @type integer | nil
    local env_name_end
    _ = stdio_stream.read(stdio_stream, '*line')
    _ = stdio_stream.read(stdio_stream, '*line')
    for line in stdio_stream.lines(stdio_stream, '*l') do -- readmode is for the output of lines as var `line`
        env_name_end, _ = string.find(line, ' ', 2) -- if cmd succeeds, the env name has to be at least 1 char long and contains no spaces. skip the first one and search for space
        env_name_end = env_name_end - 1
        if env_name_end then -- would start at 1, regardless of start index, so we don't need to differentiate between 0 and nil
            table.insert(table_lines, string.sub(line, 1, env_name_end))
        else
            vim.notify('formatting pio output failed on finding the first space char', vim.log.levels.ERROR)
            io.close(stdio_stream)
            return
        end
        _ = stdio_stream.read(stdio_stream, '*line')
    end

    io.close(stdio_stream)
    -- TODO: execute picker
end

return M
