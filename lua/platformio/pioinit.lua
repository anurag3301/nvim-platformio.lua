local M = {}

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local entry_display = require("telescope.pickers.entry_display")
local make_entry = require("telescope.make_entry")
local utils = require("platformio.utils")
local previewers = require("telescope.previewers")

local boardentry_maker = function(opts)
  local displayer = entry_display.create({
    separator = "▏",
    items = {
      { width = 35 },
      { width = 20 },
      { width = 15 },
    },
  })

  local make_display = function(entry)
    return displayer({
      entry.value.name,
      entry.value.vendor,
      entry.value.platform,
    })
  end

  return function(entry)
    return make_entry.set_default_entry_mt({
      value = {
        id = entry.id,
        name = entry.name,
        vendor = entry.vendor,
        platform = entry.platform,
        data = entry,
      },
      ordinal = entry.name .. " " .. entry.vendor .. " " .. entry.platform,
      display = make_display,
    }, opts)
  end
end

local function pick_framework(board_details)
  local opts = {}
  pickers
      .new(opts, {
        prompt_title = "frameworks",
        finder = finders.new_table({
          results = board_details["frameworks"],
        }),
        attach_mappings = function(prompt_bufnr, _)
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            local selected_framework = selection[1]
            local command = "pio project init --ide=vim --board "
                .. board_details["id"]
                .. ' --project-option "framework='
                .. selected_framework
                .. '"'
                .. utils.extra
            utils.ToggleTerminal(command, "float")
          end)
          return true
        end,
        sorter = conf.generic_sorter(opts),
      })
      :find()
end

local function pick_board(json_data)
  local opts = {}
  pickers
      .new(opts, {
        prompt_title = "Boards",
        finder = finders.new_table({
          results = json_data,
          entry_maker = opts.entry_maker or boardentry_maker(opts),
        }),
        attach_mappings = function(prompt_bufnr, _)
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            pick_framework(selection["value"]["data"])
          end)
          return true
        end,
        previewer = previewers.new_buffer_previewer({
          title = "Board Info",
          define_preview = function(self, entry, _)
            local json = utils.strsplit(vim.inspect(entry["value"]["data"]), "\n")
            vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, json)
          end,
        }),
        sorter = conf.generic_sorter(opts),
      })
      :find()
end

function M.pioinit()
  if not utils.pio_install_check() then
    return
  end

  -- Read stdout
  local command = "pio boards --json-output"
  local handel = io.popen(command .. utils.devNul)
  if not handel then
    return
  end
  local json_str = handel:read("*a")
  handel:close()

  if #json_str == 0 then
    -- read stderr
    handel = io.popen(command .. " 2>&1")
    if not handel then
      return
    end
    local command_output = handel:read("*a")
    handel:close()
    vim.notify("Some error occured while executing `" .. command .. "`', command output: \n", vim.log.levels.WARN)
    print(command_output)
    return
  end

  local json_data = vim.json.decode(json_str)
  pick_board(json_data)
end

return M
