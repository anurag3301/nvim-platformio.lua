local M = {}

local curl = require("plenary.curl")

local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local entry_display = require "telescope.pickers.entry_display"
local make_entry = require "telescope.make_entry"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local utils = require('platformio.utils')
local Terminal  = require('toggleterm.terminal').Terminal

local libentry_maker = function(opts)
  local displayer = entry_display.create {
    separator = "▏",
    items = {
      { width = 20 },
      { width = 20 },
      { remaining = true },
    },
  }

  local make_display = function(entry)
    return displayer {
      entry.value.name,
      entry.value.owner,
      entry.value.description,
    }
  end

  return function(entry)
    return make_entry.set_default_entry_mt({
      value = {
        name = entry.name,
        owner = entry.owner.username,
        description = entry.description,
      },
      ordinal = entry.name .. " " .. entry.owner.username .. " " .. entry.description,
      display = make_display,
    }, opts)
  end
end

local function pick_library(json_data)
    local opts = {}
    table.sort(json_data['items'], function(lhs, rhs)
        return lhs.popularity_rank < rhs.popularity_rank
    end)
    pickers.new(opts, {
        prompt_title = "Libraries",
        finder = finders.new_table{
            results = json_data['items'],
            entry_maker = opts.entry_maker or libentry_maker(opts),
        },
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                local selection = action_state.get_selected_entry()
                local pkg_name = selection['value']['owner'] .. "/" .. selection['value']['name']
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

        pick_library(json_data)
    else
        vim.notify("API Request to platformio return HTTP code: " .. 
        code .. "\nplease run `curl -LI " .. url .. "` for complete information", 
        vim.log.levels.ERROR)
        
    end
end

return M
