local utils = require('platformio.utils')
local terminal = require('platformio.terminal')
local M = {}

function M.piodebug(args_table)
  if not utils.pio_install_check() then
    return
  end

  local command = 'pio debug --interface=gdb -- -x .pioinit'
  -- local command = string.format('pio debug --interface=gdb -- -x .pioinit %s', utils.extra)
  terminal.ToggleTerminal(command, 'float', nil, utils.get_platformioRootDir())
end

return M
