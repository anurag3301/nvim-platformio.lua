local entries = require("platformio.piomenu_entries")
local Job = require("plenary.job")

local M = {}

local left_buf, left_win
local right_buf, right_win

function render_menu_entries()
  local lines = {}
  for _, section in ipairs(entries) do
    local line = (section.is_open and " " or " ") .. section.title
    table.insert(lines, line)

    if section.is_open then
      for _, item in ipairs(section.entries) do
        local subline = "      " .. item.title
        table.insert(lines, subline)
      end
    end
  end
  return lines
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
          -- Clicked on a command item
          return { type = "entry", command = item.command }
        end
      end
    end
  end

  return nil
end


local function run_command_in_right(command)
  vim.api.nvim_buf_set_lines(right_buf, 0, -1, false, {})

  Job:new({
    command = "sh",
    args = { "-c", command },
    on_start = function()
      vim.schedule(function()
        vim.api.nvim_buf_set_lines(right_buf, 0, -1, false, { "Executing: " .. command, "" })
        vim.api.nvim_win_set_cursor(right_win, { vim.api.nvim_buf_line_count(right_buf), 0 })
      end)
    end,
    on_stdout = function(_, line)
      vim.schedule(function()
        vim.api.nvim_buf_set_lines(right_buf, -1, -1, false, { line })
        vim.api.nvim_win_set_cursor(right_win, { vim.api.nvim_buf_line_count(right_buf), 0 })
      end)
    end,
    on_stderr = function(_, line)
      vim.schedule(function()
        vim.api.nvim_buf_set_lines(right_buf, -1, -1, false, { line })
        vim.api.nvim_win_set_cursor(right_win, { vim.api.nvim_buf_line_count(right_buf), 0 })
      end)
    end,
    on_exit = function()
      vim.schedule(function()
        vim.api.nvim_buf_set_lines(right_buf, -1, -1, false, { "-- DONE --" })
        vim.api.nvim_win_set_cursor(right_win, { vim.api.nvim_buf_line_count(right_buf), 0 })
      end)
    end,
  }):start()
end

local function setup_mouse_click_handler()
  vim.on_key(function(key)
    if key == vim.api.nvim_replace_termcodes('<LeftMouse>', true, true, true) then
      vim.defer_fn(function()
        if vim.api.nvim_get_current_win() ~= left_win then
          return
        end

        local pos = vim.api.nvim_win_get_cursor(left_win)
        local row = pos[1]
        local entry = find_clicked_entry(row)

        if entry then
          if entry.type == "section" then
            entry.section.is_open = not entry.section.is_open
            vim.api.nvim_buf_set_lines(left_buf, 0, -1, false, render_menu_entries())
          elseif entry.type == "entry" then
            run_command_in_right(entry.command)
          end
        end
      end, 0)
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
  right_buf = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_buf_set_lines(left_buf, 0, -1, false, render_menu_entries())
  vim.api.nvim_buf_set_lines(right_buf, 0, -1, false, { "Output will appear here..." })

  local content_row = main_row - 1
  local content_col = main_col + 1

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

  right_win = vim.api.nvim_open_win(right_buf, false, {
    relative = "editor",
    row = content_row,
    col = content_col + left_width + 2,
    width = right_width,
    height = content_height,
    focusable = true,
    style = "minimal",
    border = "rounded",
  })

  setup_mouse_click_handler()

  vim.api.nvim_set_current_win(left_win)

  -- Handle 'q'
  vim.api.nvim_buf_set_keymap(left_buf, 'n', 'q', '', {
    nowait = true,
    noremap = true,
    silent = true,
    callback = function()
      pcall(vim.api.nvim_win_close, right_win, true)
      pcall(vim.api.nvim_win_close, left_win, true)
    end,
  })
  vim.api.nvim_buf_set_keymap(right_buf, 'n', 'q', '', {
    nowait = true,
    noremap = true,
    silent = true,
    callback = function()
      pcall(vim.api.nvim_win_close, right_win, true)
      pcall(vim.api.nvim_win_close, left_win, true)
    end,
  })
end

return M
