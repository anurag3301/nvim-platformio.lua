local utils = require('platformio.utils')
local terminal = require('platformio.terminal')
local M = {}

function M.piocmd(cmd_table, direction)
  if not utils.pio_install_check() then
    return
  end

  if cmd_table[1] == '' then
    terminal.ToggleTerminal('', direction, nil, utils.get_platformioRootDir())
  else
    local cmd = 'pio '
    for _, v in pairs(cmd_table) do
      cmd = cmd .. ' ' .. v
    end
    terminal.ToggleTerminal(cmd, direction, nil, utils.get_platformioRootDir())
  end
end

return M
