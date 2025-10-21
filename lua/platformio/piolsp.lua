local M = {}

local utils = require('platformio.utils')
local config = require('platformio').config

function M.piolsp()
  if config.lsp == 'clangd' then 
    local command = 'pio run -t compiledb'
    utils.ToggleTerminal(command, 'float')
  elseif config.lsp == 'ccls' then
    local command = 'pio project init --ide=vim'
    utils.ToggleTerminal(command, 'float')
  else
    vim.notify('No valid LSP selected!', vim.log.levels.WARN)
  end
end

return M
