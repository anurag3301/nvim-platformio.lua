local utils = require('platformio.utils')
local Terminal  = require('toggleterm.terminal').Terminal
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
    local command = "pio " .. cmd .."; " .. utils.extra
    local term = Terminal:new({ cmd = command, direction = "float"})
    term:toggle()
  end

end

return M
