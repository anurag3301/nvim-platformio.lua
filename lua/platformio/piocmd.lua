local utils = require('platformio.utils')
local M = {}

function M.piocmd(cmd_table, direction)
  if not utils.pio_install_check() then
    return
  end

  utils.cd_pioini()

  if cmd_table[1] == '' then
    utils.ToggleTerminal('', direction)
  else
    local cmd = 'pio '
    for _, v in pairs(cmd_table) do
      cmd = cmd .. ' ' .. v
    end
    utils.ToggleTerminal(cmd, direction)
  end
end

return M
