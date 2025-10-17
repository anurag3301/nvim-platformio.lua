local utils = require('platformio.utils')
local M = {}

function M.piodb()
  if not utils.pio_install_check() then
    return
  end

  utils.cd_pioini()

  local command = 'pio run -t compiledb' -- .. utils.extra
  utils.ToggleTerminal(command, 'float')
end

return M
