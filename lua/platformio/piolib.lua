local M = {}

local http = require("socket.http")
local ltn12 = require("ltn12")

local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local utils = require('platformio.utils')

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
            vim.cmd("2TermExec cmd='pio pkg install --library \"".. pkg_name .. "\"; " .. utils.extra .. "' direction=float")
          end)
          return true
        end,
        sorter = conf.generic_sorter(opts),
    }):find()
end

function M.piolib(lib_arg_list)
    if not utils.pio_install_check() then return end

    local json_str = ""
    local lib_str = ""
    local lib_name = {}
    local lib_data = {}
    local resp= {}

    for k,v in pairs(lib_arg_list) do
        lib_str = lib_str .. v 
    end

    local url = 'https://api.registry.platformio.org/v3/search?query=%22' .. lib_str .. '%22&page=1&limit=50'

    local client, code, headers, status = http.request{url=url, sink=ltn12.sink.table(resp), method="GET"}

    if (code == 200) then

        for k,v in pairs(resp) do
            json_str = json_str .. v
        end

        local json_data = vim.json.decode(json_str)

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
