local M = {}

local utils = require('platformio.utils')
local config = require('platformio').config

function M.piolsp()
  local lsp_message = ' && echo -e "\\n\\n\\033[1;33mPlease run :LspRestart to make changes effective.\\033[0m\\n\\n"'
  if config.lsp == 'clangd' then 
    local command = 'pio run -t compiledb' .. lsp_message
    utils.ToggleTerminal(command, 'float')
  elseif config.lsp == 'ccls' then
    local command = 'pio project init --ide=vim' .. lsp_message
    utils.ToggleTerminal(command, 'float')
  else
    vim.notify('No valid LSP selected!', vim.log.levels.WARN)
  end
end

return M
