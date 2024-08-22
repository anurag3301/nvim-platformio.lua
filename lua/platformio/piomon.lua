local utils = require("platformio.utils")
local M = {}

function M.piomon(args_table)
  if not utils.pio_install_check() then
    return
  end

  utils.cd_pioini()

  local command
  local extra = "echo Press [Ctrl+C] then press ENTER to exit &&"
  if #args_table == 0 then
    command = string.format("%s pio device monitor", extra)
  else
    local baud_rate = args_table[1]
    command = string.format("%s pio device monitor -b %s", extra, baud_rate)
  end
  utils.ToggleTerminal(command, "horizontal")
end

return M
