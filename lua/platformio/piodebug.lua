local utils = require('platformio.utils')
local env = require('platformio.pioenv')
local M = {}

function M.piodebug(args_table)
    if not utils.pio_install_check() then
        return
    end

    utils.cd_pioini()

    local command = 'pio debug --interface=gdb ' .. env.get_flag() .. ' -- -x .pioinit' -- utils.extra
    -- local command = string.format('pio debug --interface=gdb -- -x .pioinit %s', utils.extra)
    utils.ToggleTerminal(command, 'float')
end

return M
