local utils = require('platformio.utils')
local M = {}

function M.piomon(args_table)
  if not utils.pio_install_check() then
    return
  end

  utils.cd_pioini()

  local command = nil
  if #args_table == 0 then
    command = 'pio device monitor'
  elseif #args_table == 1 then
    local baud_rate = args_table[1]
    command = string.format('pio device monitor -b %s', baud_rate)
  elseif #args_table == 2 then
    local baud_rate = args_table[1]
    local port = args_table[2]
    command = string.format('pio device monitor -b %s -p %s', baud_rate, port)
  end

  if command == nil then
    vim.notify('Usage: Piomon <baud> <port>', vim.log.levels.ERROR)
  else
    utils.ToggleTerminal(command, 'horizontal')
  end
end

return M
