local M = {}

local curl = require('plenary.curl')
local utils = require('platformio.utils')
local picker = require('platformio.pickers')

function M.piolib(lib_arg_list)
  if not utils.pio_install_check() then
    return
  end

  local lib_str = ''

  for _, v in pairs(lib_arg_list) do
    lib_str = lib_str .. v .. '+'
  end

  local url = 'https://api.registry.platformio.org/v3/search'
  local res = curl.get(url, {
    insecure = utils.is_windows, -- Windows curl builds often lack a CA bundle, breaking TLS verification
    timeout = 20000,
    headers = { content_type = 'application/json' },
    query = {
      query = lib_str,
      limit = 30,
      sort = 'popularity',
      -- page = 1,
      -- limit = 1,
    },
  })

  if res['status'] == 200 then
    local json_data = vim.json.decode(res['body'])
    picker.pick_library(json_data.items or {}, function(selected_library)
      local owner = utils.sanitize_shell_arg((selected_library.owner and selected_library.owner.username) or '')
      local name = utils.sanitize_shell_arg(selected_library.name or '')
      if owner == '' or name == '' then
        vim.notify('Invalid library selection: missing owner or name.', vim.log.levels.ERROR)
        return
      end
      local pkg_name = owner .. '/' .. name
      local command = 'pio pkg install --library "' .. pkg_name .. '"'
      utils.ToggleTerminal(command, 'float', function()
        vim.cmd(':PioLSP')
      end, utils.get_platformioRootDir())
    end)
  else
    vim.notify(
      'API Request to platformio return HTTP code: ' .. res['status'] .. '\nplease run `curl -LI ' .. url .. '` for complete information',
      vim.log.levels.ERROR
    )
  end
end

return M
