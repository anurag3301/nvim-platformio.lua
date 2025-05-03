local entries = require("platformio.piomenu_entries")
local Terminal = require('toggleterm.terminal').Terminal
local utils = require 'platformio.utils'

local M = {}

local left_buf, left_win
local menu_term

function render_menu_entries()
  local lines = {}
  local highlights = {}

  for _, section in ipairs(entries) do
    local line = (section.is_open and " " or " ") .. section.title
    table.insert(lines, line)
    table.insert(highlights, { hl_group = "Function", linenr = #lines - 1 })

    if section.is_open then
      for _, item in ipairs(section.entries) do
        local subline = "    " .. item.title
        table.insert(lines, subline)
        table.insert(highlights, { hl_group = "String", linenr = #lines - 1 })
      end
    end
  end

  vim.api.nvim_buf_set_lines(left_buf, 0, -1, false, lines)

  for _, hl in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(left_buf, -1, hl.hl_group, hl.linenr, 0, -1)
  end
end

local function find_clicked_entry(row)
  local current_line = 0

  for _, section in ipairs(entries) do
    current_line = current_line + 1
    if row == current_line then
      return { type = "section", section = section }
    end

    if section.is_open then
      for _, item in ipairs(section.entries) do
        current_line = current_line + 1
        if row == current_line then
          return { type = "entry", command = item.command }
        end
      end
    end
  end

  return nil
end


local function handel_interaction()
  if vim.api.nvim_get_current_win() ~= left_win then
    return
  end

  local pos = vim.api.nvim_win_get_cursor(left_win)
  local row = pos[1]
  local entry = find_clicked_entry(row)

  if entry then
    if entry.type == "section" then
      entry.section.is_open = not entry.section.is_open
      render_menu_entries()
    elseif entry.type == "entry" then
      menu_term:send(entry.command, true)
    end
  end
end

local function setup_mouse_click_handler()
  vim.on_key(function(key)
    if key == vim.api.nvim_replace_termcodes('<LeftMouse>', true, true, true) then
      vim.defer_fn(handel_interaction, 0)
    end
  end, vim.api.nvim_create_namespace('mouse_click_ns'))
end

function M.piomenu()
  -- Calculate sizes
  local main_width = math.floor(vim.o.columns * 0.9)
  local main_height = math.floor(vim.o.lines * 0.9)
  local main_row = math.floor((vim.o.lines - main_height) / 2)
  local main_col = math.floor((vim.o.columns - main_width) / 2)

  local content_width = main_width - 2
  local content_height = main_height - 2
  local left_width = math.floor(content_width * 0.2)
  local right_width = content_width - left_width

  left_buf = vim.api.nvim_create_buf(false, true)

  render_menu_entries()

  local content_row = main_row - 1
  local content_col = main_col + 1

  menu_term = Terminal:new {
    cmd = vim.o.shell,
    dir = utils.get_pioini_path(),
    direction = "float",
    auto_scroll = true,
    float_opts = {
      row = content_row,
      col = content_col + left_width + 2,
      width = right_width,
      height = content_height,
      winblend = 3,
    },
    on_close = function(t)
      pcall(vim.api.nvim_win_close, left_win, true)
    end

  }
  menu_term:toggle()


  left_win = vim.api.nvim_open_win(left_buf, true, {
    relative = "editor",
    row = content_row,
    col = content_col,
    width = left_width,
    height = content_height,
    focusable = true,
    style = "minimal",
    border = "rounded",
  })
  vim.cmd("stopinsert")

  setup_mouse_click_handler()

  vim.api.nvim_set_current_win(left_win)

  -- Handle 'q'
  vim.api.nvim_buf_set_keymap(left_buf, 'n', 'q', '', {
    nowait = true,
    noremap = true,
    silent = true,
    callback = function()
      menu_term:send("exit", true)
      pcall(vim.api.nvim_win_close, left_win, true)
    end,
  })

  vim.api.nvim_buf_set_keymap(menu_term["bufnr"], 'n', 'q', '', {
    nowait = true,
    noremap = true,
    silent = true,
    callback = function()
      menu_term:send("exit", true)
      pcall(vim.api.nvim_win_close, left_win, true)
    end,
  })

  vim.api.nvim_buf_set_keymap(left_buf, 'n', '<CR>', '', {
    noremap = true,
    silent = true,
    callback = handel_interaction,
  })
end

return M
