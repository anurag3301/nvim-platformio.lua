local actions = require "telescope.actions"
local action_set = require "telescope.actions.set"
local action_state = require "telescope.actions.state"
local finders = require "telescope.finders"
local make_entry = require "telescope.make_entry"
local pickers = require "telescope.pickers"
local entry_display = require "telescope.pickers.entry_display"
local previewers = require "telescope.previewers"

local conf = require("telescope.config").values


local function read_file(path)
    local file = io.open(path, "rb") -- r read mode and b binary mode
    if not file then return nil end
    local content = file:read "*a" -- *a or *all reads the whole file
    file:close()
    return content
end

local fileContent = read_file("data.json");
local json_data = vim.json.decode(fileContent)
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
      { entry.value.name, "vimAutoEvent" },
      entry.value.owner,
      entry.value.command,
    }
  end

  return function(entry)
    return make_entry.set_default_entry_mt({
      value = {
        name = entry.name,
        owner = entry.owner.username,
        command = entry.description,
        data = entry
      },
      --
      ordinal = entry.name .. " " .. entry.owner.username .. " " .. entry.description,
      display = make_display,
    }, opts)
  end
end

function strsplit (inputstr, del)
    local t={}
    for str in string.gmatch(inputstr, "([^".. del .."]+)") do
        table.insert(t, str)
    end
    return t
end


-- our picker function: colors
local colors = function(opts)
  table.sort(json_data['items'], function(lhs, rhs)
    return lhs.popularity_rank < rhs.popularity_rank
  end)
  pickers
    .new(opts, {
      prompt_title = "autocommands",
      finder = finders.new_table {
        results = json_data['items'],
        entry_maker = opts.entry_maker or libentry_maker(opts),
      },
      -- previewer = previewers.autocommands.new(opts),
        attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            local pkg_name = selection['value']['owner'] .. "/" .. selection['value']['name']
            local command = "pio pkg install --library \"".. pkg_name .. "\"; "
            print(command)
          end)
          return true
        end,
    previewer = previewers.new_buffer_previewer {
      title = "My preview",
      define_preview = function (self, entry, status)
        local json = strsplit(vim.inspect(entry['value']['data']), "%s")
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, json)
      end
    },

      sorter = conf.generic_sorter(opts),
    })
    :find()
end
-- to execute the function
colors({})

