local utils = require('platformio.utils')
local Terminal  = require('toggleterm.terminal').Terminal
local M = {}

function M.piomon(args_table)
  if not utils.pio_install_check() then return end

  utils.cd_pioini()

  if(#args_table==0)then
    local command = string.format("pio device monitor; %s", utils.extra)
    local term = Terminal:new({cmd = command, direction = "float"})
    term:toggle()
  else
    local baud_rate = args_table[1]
    local command = string.format("pio device monitor -b %s; %s", baud_rate, utils.extra)
    local term = Terminal:new({cmd = command, direction = "float"})
    term:toggle()
  end

end

return M
