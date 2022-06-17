local utils = require('platformio.utils')
local M = {}

function M.piomon(args_table)
    if not utils.pio_install_check() then return end

    utils.cd_pioini()

    if(#args_table==0)then
        vim.cmd(string.format("2TermExec cmd='pio device monitor; %s' direction=float", utils.extra))
    else
        local baud_rate = args_table[1]
        vim.cmd(string.format("2TermExec cmd='pio device monitor -b %s; %s ' direction=float", baud_rate, utils.extra))
    end

end

return M
