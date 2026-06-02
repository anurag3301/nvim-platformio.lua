local utils = require('platformio.utils')
local M = {}

function M.pioenv()
    if not utils.pio_install_check() then
        return
    end
    utils.cd_pioini()

    vim.notify('hi', vim.log.levels.INFO)

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
    vim.notify(io.read('*a'), vim.log.levels.INFO)

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

    -- --- @type string[]
    -- local table_lines = {}
    -- --- @type integer | nil
    -- local env_name_end
    -- for line in stdio_stream.lines(stdio_stream, '*a') do
    --     if line == '' then -- discard empty lines
    --         goto continue
    --     end
    --     env_name_end, _ = string.find(line, ' ', 2) -- if cmd succeeds, the env name has to be at least 1 char long and contains no spaces. skip the first one and search for space
    --     env_name_end = env_name_end - 1
    --     if env_name_end then -- would start at 1, regardless of start index, so we don't need to differentiate between 0 and nil
    --         table.insert(table_lines, string.sub(line, env_name_end))
    --     else
    --         vim.notify('formatting pio output failed on finding the first space char', vim.log.levels.ERROR)
    --         return
    --     end
    --     ::continue::
    -- end

    -- local output_filepath = utils.make_os_user_data_dir() .. '/formatted_lines.md'
    -- vim.notify(output_filepath, vim.log.levels.INFO)
    -- for _, line in ipairs(table_lines) do
    --     if not os.execute('echo "' .. line .. '" >> ' .. output_filepath) then
    --         vim.notify('writing to file failed', vim.log.levels.ERROR)
    --         stdio_stream:close()
    --         return
    --     end
    -- end

    io.close(stdio_stream)
    -- TODO: parse output
    -- TODO: execute picker
end

return M
