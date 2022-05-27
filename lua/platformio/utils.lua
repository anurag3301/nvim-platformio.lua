local M = {}

M.extra = 'echo \"\\\\n\\\\033[0;33mPlease Press ENTER to continue \\\\033[0m\"; read; exit;'

function M.strsplit (inputstr)
    local t={}
    for str in string.gmatch(inputstr, "([^%s]+)") do
        table.insert(t, str)
    end
    return t
end


local paths = {'.', '..', '../..', '../../..'}
local inipath = ''

function M.file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

function M.cd_pioini()
    for k, v in pairs(paths) do
        if M.file_exists(v .. '/platformio.ini') then
            inipath = v
            break
        end
    end

    vim.cmd('cd ' .. inipath)
end

return M
