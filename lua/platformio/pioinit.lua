local M = {}

local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local utils = require('platformio.utils')

local board_data = {}
local board_names = {}
local selected_board_id, selected_board_name, selected_board_framework

local function pick_framework()
    local opts = opts or {}
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
            vim.cmd("2TermExec cmd='pio project init --board ".. selected_board_id .. " --project-option=\"framework=" .. selected_board_framework .. "\"; " .. utils.extra .. "' direction=float")
          end)
          return true
        end,
        sorter = conf.generic_sorter(opts),
    }):find()
end

local function pick_board ()
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
    
    if not utils.pio_install_check() then return end

    local handel = io.popen('pio boards --json-output')
    local json_str = handel:read("*a")
    handel:close()

    local json_data = require('lunajson').decode(json_str)

    for i,v in pairs(json_data) do
        board_data[v['name']] = v
        table.insert(board_names, v['name'])
    end
    pick_board()
end

return M
