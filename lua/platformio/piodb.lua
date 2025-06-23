local M = {}

local utils = require("platformio.utils")

function M.piodb()
  local command = "pio run -t compiledb" -- .. utils.extra
  utils.ToggleTerminal(command, "float")
end

return M
