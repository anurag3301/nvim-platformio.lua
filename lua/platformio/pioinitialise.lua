local M = {}

local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

local board_data = {}
local board_names = {}
local selected_board_id, selected_board_name, selected_board_framework


function pick_framework()
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
            print(selected_board_name, selected_board_id, selected_board_framework)
          end)
          return true
        end,
        sorter = conf.generic_sorter(opts),
    }):find()
end

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
            pick_framework()
          end)
          return true
        end,
        sorter = conf.generic_sorter(opts),
    }):find()
end

function M.pioinit(board)
    local handel = io.popen('pio boards --json-output')
    local json_str = handel:read("*a")
    handel:close()

    local json_data = require('lunajson').decode(json_str)

    for i,v in pairs(json_data) do
        board_data[v['name']] = v
        table.insert(board_names, v['name'])
    end


    pick_board()


    -- vim.cmd("2TermExec cmd='pio project init --board ".. selected_board_id .. "' direction=float")

end

return M
