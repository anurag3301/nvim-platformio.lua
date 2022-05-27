local M = {}

local function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

local paths = {'.', '..', '../..', '../../..'}
local inipath = ''
local extra = 'echo \"\\\\n\\\\033[0;33mPlease Press ENTER to continue \\\\033[0m\"; read; exit;'

local function cd_pioini()
    for k, v in pairs(paths) do
        if file_exists(v .. '/platformio.ini') then
            inipath = v
            break
        end
    end

    vim.cmd('cd ' .. inipath)
end

function M.piobuild()
    cd_pioini()
    vim.cmd("2TermExec cmd='pio run; " .. extra .. "' direction=float")
end

function M.pioupload()
    cd_pioini()
    vim.cmd("2TermExec cmd='pio run --target upload; " .. extra .. "' direction=float")
end

return M