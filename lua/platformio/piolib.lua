local M = {}

local curl = require("plenary.curl")

local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local utils = require('platformio.utils')
local Terminal  = require('toggleterm.terminal').Terminal

local function pick_library(args)
    local opts = {}
    pickers.new(opts, {
        prompt_title = "Libraries",
        finder = finders.new_table{
            results = args.lib_name,
        },
        attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            selected_library = selection[1]
            local pkg_name = args['lib_data'][selected_library]['owner']['username'] .. "/" .. selected_library
            local command = "pio pkg install --library \"".. pkg_name .. "\"; " .. utils.extra
            local term = Terminal:new({cmd = command, direction = "float"})
            term:toggle()
          end)
          return true
        end,
        sorter = conf.generic_sorter(opts),
    }):find()
end

function M.piolib(lib_arg_list)
    if not utils.pio_install_check() then return end

    local lib_str = ""
    local lib_name = {}
    local lib_data = {}

    for k,v in pairs(lib_arg_list) do
        lib_str = lib_str .. v
    end

    local url = 'https://api.registry.platformio.org/v3/search?query="' .. lib_str .. '"&page=1&limit=50'

    local res = curl.get(url, {accept = "application/json"})

    if (res['status'] == 200) then
        local json_data = vim.json.decode(res['body'])

        for k,v in pairs(json_data['items']) do
            lib_data[v['name']] = v
            table.insert(lib_name, v['name'])
        end

        pick_library({['lib_name']=lib_name, ['lib_data']=lib_data})
    else
        vim.notify("API Request to platformio return HTTP code: " .. 
        code .. "\nplease run `curl -LI " .. url .. "` for complete information", 
        vim.log.levels.ERROR)
        
    end
end

return M
