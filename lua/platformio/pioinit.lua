local M = {}

local utils = require('platformio.utils')
local picker = require('platformio.pickers')
local boilerplate_gen = require('platformio.boilerplate').boilerplate_gen

local function init_project(board_details, selected_framework)
  local framework = selected_framework
  if framework == 'none' then
    framework = ''
  end
  local command = 'pio project init --board ' .. board_details.id .. ' --project-option "framework=' .. framework .. '"'
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
  local handle = io.popen(command .. utils.devNul)
  if not handle then
    return
  end
  local json_str = handle:read('*a')
  handle:close()

  if #json_str == 0 then
    -- read stderr
    handle = io.popen(command .. ' 2>&1')
    if not handle then
      return
    end
    local command_output = handle:read('*a')
    handle:close()
    vim.notify('Some error occured while executing `' .. command .. "`', command output: \n", vim.log.levels.WARN)
    print(command_output)
    return
  end

  local json_data = vim.json.decode(json_str)
  pick_board(json_data or {})
end

return M
