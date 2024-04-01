local utils = require('platformio.utils')
local Terminal  = require('toggleterm.terminal').Terminal
local M = {}

function M.piodebug(args_table)
  if not utils.pio_install_check() then return end

  utils.cd_pioini()

  local command = string.format("pio debug --interface=gdb -- -x .pioinit; %s", utils.extra)
  local term = Terminal:new({cmd = command, direction = "float"})
  term:toggle()

end

return M
