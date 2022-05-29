local M = {}

local utils = require('platformio.utils')

function M.piobuild()
    utils.cd_pioini()
    vim.cmd("2TermExec cmd='pio run; " .. utils.extra .. "' direction=float")
end

function M.pioupload()
    utils.cd_pioini()
    vim.cmd("2TermExec cmd='pio run --target upload; " .. utils.extra .. "' direction=float")
end

function M.pioclean()
    utils.cd_pioini()
    vim.cmd("2TermExec cmd='pio run --target clean; " .. utils.extra .. "' direction=float")
end

function M.piorun(arg)
    if(arg == nil)then
        arg = 'upload'
    end

    arg = utils.strsplit(arg)[1]
    if(arg == 'upload')then
        M.pioupload()
    elseif(arg == 'build')then
        M.piobuild()
    elseif(arg == 'clean')then
        M.pioclean()
    else
        print("Invalid argument: build, upload or clean")
    end

end

return M
