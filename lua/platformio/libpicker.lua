local actions = require "telescope.actions"
local action_set = require "telescope.actions.set"
local action_state = require "telescope.actions.state"
local finders = require "telescope.finders"
local make_entry = require "telescope.make_entry"
local pickers = require "telescope.pickers"
local entry_display = require "telescope.pickers.entry_display"

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
      { width = 14 },
      { width = 18 },
      { remaining = true },
    },
  }

  local make_display = function(entry)
    return displayer {
      { entry.value.name, "vimAutoEvent" },
      { entry.value.owner, "vimAugroup" },
      entry.value.command,
    }
  end

  return function(entry)
    return make_entry.set_default_entry_mt({
      value = {
        name = entry.name,
        owner = entry.owner.username,
        command = entry.description,
      },
      --
      ordinal = entry.name .. " " .. entry.owner.username .. " " .. entry.description,
      display = make_display,
    }, opts)
  end
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
      sorter = conf.generic_sorter(opts),
    })
    :find()
end
-- to execute the function
colors({})
