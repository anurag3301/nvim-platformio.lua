local entries = require("platformio.piomenu_entries")

local M = {}

local function setup_mouse_click_handler(buf, win)
  vim.on_key(function(key)
    if key == vim.api.nvim_replace_termcodes('<LeftMouse>', true, true, true) then
      -- Mouse clicked
      local pos = vim.api.nvim_win_get_cursor(win)
      local row = pos[1]
      local col = pos[2]
      local line = vim.api.nvim_buf_get_lines(buf, row - 1, row, false)[1] or ""

        vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
          "Hello World",
          "This is line 2",
          "Another line"
        })
      print(string.format("Mouse click: row=%d col=%d char='%s'", row, col, line:sub(col + 1, col + 1)))
    end
  end, vim.api.nvim_create_namespace('mouse_click_ns'))
end

function M.open_floating_window()
  -- Calculate main window size (80% of screen)
  local main_width = math.floor(vim.o.columns * 0.8)
  local main_height = math.floor(vim.o.lines * 0.8)
  local main_row = math.floor((vim.o.lines - main_height) / 2)
  local main_col = math.floor((vim.o.columns - main_width) / 2)

  -- Calculate content area size inside the border
  local content_width = main_width - 2
  local content_height = main_height - 2
  local left_width = math.floor(content_width * 0.2)
  local right_width = content_width - left_width

  -- Create two buffers
  local left_buf = vim.api.nvim_create_buf(false, true)
  local right_buf = vim.api.nvim_create_buf(false, true)

  -- Write some text inside each
  vim.api.nvim_buf_set_lines(left_buf, 0, -1, false, {
    "LEFT COLUMN",
    "20% WIDTH",
  })
  vim.api.nvim_buf_set_lines(right_buf, 0, -1, false, {
    "RIGHT COLUMN",
    "80% WIDTH",
    "This is a bigger pane.",
  })

  -- Calculate absolute positions for content inside the main border
  local content_row = main_row + 1
  local content_col = main_col + 1

  -- Open left window (20% pane)
  local left_win = vim.api.nvim_open_win(left_buf, false, {
    relative = "editor",
    row = content_row,
    col = content_col,
    width = left_width,
    height = content_height,
    focusable = true,
    style = "minimal",
    border = "rounded",
  })

  -- Open right window (80% pane)
  local right_win = vim.api.nvim_open_win(right_buf, false, {
    relative = "editor",
    row = content_row,
    col = content_col + left_width+2,
    width = right_width,
    height = content_height,
    focusable = false,
    style = "minimal",
    border = "rounded",
  })


setup_mouse_click_handler(left_buf, left_win)
vim.api.nvim_set_current_win(left_win)


  -- Handle 'q' key
  vim.api.nvim_buf_set_keymap(left_buf, 'n', 'q', '', {
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
