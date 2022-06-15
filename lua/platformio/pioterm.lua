local utils = require('platformio.utils')
local M = {}

function M.piocmd(cmd_table)
    if not utils.pio_install_check() then return end

    utils.cd_pioini()

    if(#cmd_table==0)then
        vim.cmd("2ToggleTerm direction=float")
    else
        local cmd = ''
        for k,v in pairs(cmd_table)do
            cmd = cmd .. " " .. v
        end
        vim.cmd("2TermExec cmd='pio " .. cmd .."; " .. utils.extra .. "' direction=float")
    end

end

return M
