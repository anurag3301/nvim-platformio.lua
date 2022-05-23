local handel = io.popen('pio boards --json-output')
local json_str = handel:read("*a")
handel:close()

local json_data = require('lunajson').decode(json_str)
local board_data = {}
local board_names = {}

for i,v in pairs(json_data) do
    board_data[v['name']] = v
    table.insert(board_names, v['name'])
end

-- for i,v in pairs(board_name) do
--     print(i, v)
-- end

local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values

local pick_board= function(opts)
  opts = opts or {}
  pickers.new(opts, {
    prompt_title = "Boards",
    finder = finders.new_table {
      results = board_names
    },
    sorter = conf.generic_sorter(opts),
  }):find()
end

pick_board()
