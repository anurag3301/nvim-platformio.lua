local M = {}

local utils = require('platformio.utils')
local picker = require('platformio.pickers')
local boilerplate_gen = require('platformio.boilerplate').boilerplate_gen

local function init_project(board_details, selected_framework)
  local framework = selected_framework
  if framework == 'none' then
    framework = ''
  end
  local board_id = utils.sanitize_shell_arg(board_details.id)
  local framework_arg = utils.sanitize_shell_arg(framework)
  local command = 'pio project init --board ' .. board_id .. ' --project-option "framework=' .. framework_arg .. '"'
  utils.ToggleTerminal(command, 'float', function()
    vim.cmd(':PioLSP')
    boilerplate_gen(framework)
  end)
end

local function pick_framework(board_details)
  local framework_list = vim.list_extend({ 'none' }, board_details.frameworks or {})
  picker.pick_framework(framework_list, function(selected_framework)
    init_project(board_details, selected_framework)
  end)
end

local function pick_board(boards)
  picker.pick_board(boards, function(selected_board)
    pick_framework(selected_board)
  end)
end

function M.pioinit()
  if not utils.pio_install_check() then
    return
  end

  -- Read stdout
  local command = 'pio boards --json-output'
  local handel = io.popen(command .. utils.devNul)
  if not handel then
    return
  end
  local json_str = handel:read('*a')
  handel:close()

  if #json_str == 0 then
    -- read stderr
    handel = io.popen(command .. ' 2>&1')
    if not handel then
      return
    end
    local command_output = handel:read('*a')
    handel:close()
    vim.notify('Some error occured while executing `' .. command .. "`', command output: \n", vim.log.levels.WARN)
    print(command_output)
    return
  end

  local json_data = vim.json.decode(json_str)
  pick_board(json_data or {})
end

return M
