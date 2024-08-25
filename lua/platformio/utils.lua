local M = {}

-- M.extra = 'printf \"\\\\n\\\\033[0;33mPlease Press ENTER to continue \\\\033[0m\"; read'
M.extra = " && echo . && echo . && echo Please Press ENTER to continue"

function M.strsplit(inputstr, del)
  local t = {}
  for str in string.gmatch(inputstr, "([^" .. del .. "]+)") do
    table.insert(t, str)
  end
  return t
end

local function pathmul(n)
  return ".." .. string.rep("/..", n)
end
----------------------------------------------------------------------------------------
function M.ToggleTerminal(command, direction, title)
  local Terminal = require("toggleterm.terminal").Terminal
  local terminal = Terminal:new({
    cmd = command,
    direction = direction,
    close_on_exit = false,
    on_create = function(t)
      if title then
        vim.api.nvim_set_hl(0, "MyWinBar", { bg = "#e4f00e", fg = "#0012d9" })
        local value = "%#MyWinBar#" .. title .. "%*"
        vim.api.nvim_set_option_value("winbar", value, { scope = "local", win = t.window })
      end

      local platformio = vim.api.nvim_create_augroup("platformio", { clear = true })
      vim.api.nvim_create_autocmd({ "QuitPre" }, {
        group = platformio, --fmt_group,
        desc = "close terminl",
        callback = function()
          local wbuf = vim.api.nvim_win_get_buf(0)
          if wbuf == t.bufnr then
            vim.api.nvim_buf_delete(wbuf, { force = true })
          end
        end,
      })
    end,
  })
  terminal:toggle()
end

function M.TerminalOut(command)
  local width = vim.api.nvim_get_option_value("columns", {})
  local height = vim.api.nvim_get_option_value("lines", {})
  -- calculate our floating window size
  local win_height = math.ceil(height * 0.8 - 4)
  local win_width = math.ceil(width * 0.8)
  -- and its starting position
  local row = math.ceil((height - win_height) / 2.1 - 1)
  local col = math.ceil((width - win_width) / 2.1)
  local jobid
  --
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_open_win(bufnr, true, {
    relative = "win",
    border = { "╔", "═", "╗", "║", "╝", "═", "╚", "║" },
    width = win_width,
    style = "minimal",
    height = win_height,
    row = row,
    col = col,
  })
  --
  local chan = vim.api.nvim_open_term(bufnr, {
    on_input = function(_, _, _, data)
      if jobid then
        pcall(vim.api.nvim_chan_send, jobid, data)
      end
    end,
  })
  -- Echo the command to output termainal
  vim.api.nvim_chan_send(chan, vim.fn.getcwd() .. " > " .. command .. "\r\n\r\n\r\n")
  --
  local opts = {
    pty = true,
    -- stdin = "pipe",
    on_stdout = function(_, data)
      vim.api.nvim_chan_send(chan, table.concat(data, "\r\n"))
    end,
    on_exit = function(_, exit_code)
      vim.api.nvim_chan_send(chan, "\r\n\r\n[Process exited " .. tostring(exit_code) .. "]")
      vim.api.nvim_chan_send(chan, "\r\n\r\nPress <ENTER> to close this window.")
      vim.api.nvim_buf_set_keymap(bufnr, "n", "<CR>", "<cmd>bd!<CR>", { noremap = true, silent = true })
    end,
  }
  -- Send the command to terminal
  jobid = vim.fn.jobstart(command, opts)
end

local is_windows = jit.os == "Windows"
--
M.devNul = is_windows and " 2>./nul" or " 2>/dev/null"
----------------------------------------------------------------------------------------

local paths = { ".", "..", pathmul(1), pathmul(2), pathmul(3), pathmul(4), pathmul(5) }

function M.file_exists(name)
  local f = io.open(name, "r")
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

function M.cd_pioini()
  for _, path in pairs(paths) do
    if M.file_exists(path .. "/platformio.ini") then
      vim.cmd("cd " .. path)
      break
    end
  end
end

function M.pio_install_check()
  local handel = (jit.os == "Windows") and assert(io.popen("where.exe pio 2>./nul"))
      or assert(io.popen("which pio 2>/dev/null"))
  local pio_path = assert(handel:read("*a"))
  handel:close()

  if #pio_path == 0 then
    vim.notify("Platformio not found in the path", vim.log.levels.ERROR)
    return false
  end
  return true
end

return M
