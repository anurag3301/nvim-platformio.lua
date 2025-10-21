local utils = require('platformio.utils')
local M = {}

function M.piomon(args_table)
  if not utils.pio_install_check() then
    return
  end

  utils.cd_pioini()

  local command
  if args_table[1] == '' then
    command = 'pio device monitor'
  else
    local baud_rate = args_table[1]
    command = string.format('pio device monitor -b %s', baud_rate)
  end
  utils.ToggleTerminal(command, 'horizontal')
end

return M
