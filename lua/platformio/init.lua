
local M = {}
local default_config = {
  lsp = 'ccls',
  menu_key = '<leader>p',
}

M.config = vim.deepcopy(default_config)

function M.setup(user_config)
  local valid_keys = {
    lsp = true,
    menu_key = true,
  }
  for key, _ in pairs(user_config or {}) do
    if not valid_keys[key] then
      local error_message = string.format("Invalid configuration key: '%s'\n%s", key, debug.traceback 'Stack trace:')
      vim.api.nvim_echo({ { error_message, 'ErrorMsg' } }, true, {}) -- replaced deprecated function
      return
    end
  end
  M.config = vim.tbl_deep_extend('force', default_config, user_config or {})
  require('platformio.piomenu').piomenu(M.config)
end

return M
