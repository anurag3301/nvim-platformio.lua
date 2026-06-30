local utils = require('platformio.utils')
local env = require('platformio.pioenv')
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
    if env.command_accepts_flag(cmd_table[1]) then
      cmd = cmd .. env.get_flag()
    end
    utils.ToggleTerminal(cmd, direction)
  end
end

return M
