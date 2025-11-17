local M = {}
local utils = require('platformio.utils')

M.tty_list = {}

function M.parse_tty(lines)
  for k in pairs(M.tty_list) do
    M.tty_list[k] = nil
  end
  local json_data = vim.json.decode(lines[1])
  for key, value in pairs(json_data) do
    if value['description'] ~= 'n/a' then
      table.insert(M.tty_list, { port = value['port'], description = value['description'] })
    end
  end
end

function M.sync_ttylist()
  utils.async_shell_cmd({ 'platformio', 'device', 'list', '--json-output' }, M.parse_tty)
end

function M.sync_ttylist_await()
  local done = false
  local result = nil

  utils.async_shell_cmd({ 'platformio', 'device', 'list', '--json-output' }, function(lines, code)
    result = { lines = lines, code = code }
    done = true
  end)

  vim.wait(3000, function()
    return done
  end, 10)

  if result then
    M.parse_tty(result.lines)
  end
end

function M.print_tty_list()
  M.sync_ttylist_await()
  local lines = {}

  for _, item in ipairs(M.tty_list) do
    table.insert(lines, string.format('%s - %s', item.port, item.description))
  end

  print(table.concat(lines, '\n'))
end

return M
