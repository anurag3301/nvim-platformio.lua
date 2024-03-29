local M = {}

M.extra = 'printf \"\\\\n\\\\033[0;33mPlease Press ENTER to continue \\\\033[0m\"; read'

function M.strsplit (inputstr, del)
  local t={}
  for str in string.gmatch(inputstr, "([^".. del .."]+)") do
    table.insert(t, str)
  end
  return t
end

local function pathmul(n)
  return '..' .. string.rep('/..', n)
end

local paths = {'.', '..', pathmul(1), pathmul(2), pathmul(3), pathmul(4), pathmul(5)}

function M.file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

function M.cd_pioini()
  for k, path in pairs(paths) do
    if M.file_exists(path .. '/platformio.ini') then
      vim.cmd('cd ' .. path)
      break
    end
  end
end

function M.pio_install_check()
  local handel = assert(io.popen('which pio 2>/dev/null'))
  local pio_path = assert(handel:read("*a"))
  handel:close()

  if #pio_path == 0 then
    vim.notify("Platformio not found in the path", vim.log.levels.ERROR)
    return false
  end
  return true
end

return M
