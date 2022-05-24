local handel = io.popen('pio boards --json-output')
local json_str = handel:read("*a")
handel:close()

local json_data = require('lunajson').decode(json_str)
board_data = {}
local board_names = {}

for i,v in pairs(json_data) do
    board_data[v['name']] = v
    table.insert(board_names, v['name'])
end

local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local selected_board_id, selected_board_name, selected_board_framework

local pick_board = function()
    local opts = opts or {}
    pickers.new(opts, {
        prompt_title = "Boards",
        finder = finders.new_table{
            results = board_names,
        },
        attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            selected_board_name = selection[1]
            selected_board_id = board_data[selection[1]]['id']
            framework_pick()
          end)
          return true
        end,
        sorter = conf.generic_sorter(opts),
    }):find()
end

function framework_pick()
    pickers.new(opts, {
        prompt_title = "frameworks",
        finder = finders.new_table{
            results = board_data[selected_board_name]['frameworks'],
        },
        attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            selected_board_framework = selection[1]
          end)
          return true
        end,
        sorter = conf.generic_sorter(opts),
    }):find()
end

pick_board()
