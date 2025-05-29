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

-------------------------------------------------
local function setMode(target_mode)
  if target_mode == "n" or target_mode == "nt" or target_mode == "normal" or target_mode == "normal_terminal" then
    local esc_key = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
    vim.api.nvim_feedkeys(esc_key, "n", false)
    vim.api.nvim_feedkeys(esc_key, "n", false) -- Sending Esc twice is a common robust way
  elseif target_mode == "i" or target_mode == "t" or target_mode == "insert" or target_mode == "terminal" then
    vim.api.nvim_feedkeys("i", "n", false)
  elseif target_mode == "v" or target_mode == "visual" then
    vim.api.nvim_feedkeys("v", "n", false)
  elseif target_mode == "V" or target_mode == "visual_line" then
    vim.api.nvim_feedkeys("V", "n", false)
  else
    vim.api.nvim_echo({ { "Error: Unknown target mode '" .. target_mode .. "'", "ErrorMsg" } }, true, {})
    return
  end
  -- Short delay to allow mode change to process, then get new mode
  vim.defer_fn(function() end, 100) -- 100ms delay
end
---------------------------------------------
---------------------------------------------
function M.ToggleTerminal(command, direction)
  local status_ok, _ = pcall(require, "toggleterm")
  if not status_ok then
    vim.api.nvim_echo({ { "toggleterm not found!", "ErrorMsg" } }, true, {})
    return
  end

  local platformio = vim.api.nvim_create_augroup("platformio", { clear = true })
  local origin_window = nil -- used to keep previous window id; to go back to after closing terminal

  local title = "Pio CLI> " .. command
  local id = 1 -- 2 for monitor terminal, 1 for other
  if string.find(command, " monitor") then
    title = "Pio CLI Monitor: Press [Ctrl+C] then press ENTER to exit"
    id = 2
  end
  ------------------------------------------------------
  ------termConfig: terminal configuration table--------
  local termConfig = {
    id = id,
    direction = direction,
    float_opts = {
      winblend = 0,
      width = function()
        return math.ceil(vim.o.columns * 0.85)
      end,
      height = function()
        return math.ceil(vim.o.lines * 0.85)
      end,
      highlights = {
        border = "FloatBorder",
        background = "NormalFloat",
      },
    },
    close_on_exit = false,
    on_open = function(t)
      local hl = { bg = "#e4cf0e", fg = "#0012d9" }
      vim.api.nvim_set_hl(0, "MyWinBar", { bg = hl.bg, fg = hl.fg })

      local winBarTitle = "%#MyWinBar#" .. title .. "%*"
      vim.api.nvim_set_option_value("winbar", winBarTitle, { scope = "local", win = t.window })

      -- Following necessary to solve that some time winbar not showing
      vim.schedule(function()
        vim.api.nvim_set_option_value("winbar", winBarTitle, { scope = "local", win = t.window })
      end)
      vim.api.nvim_echo({
        { "ToggleTerm ",                                   "MoreMsg" },
        { "(Previous window ID: " .. origin_window .. ")", "MoreMsg" },
        { "(Window ID: " .. t.window .. ")",               "MoreMsg" },
        { "(terminal id: " .. t.id .. ")",                 "MoreMsg" },
        { "(Job ID: " .. t.job_id .. ")",                  "MoreMsg" },
      }, true, {})
    end,
    on_create = function(t)
      --set toggleterm to be in terminal mode
      setMode("terminal")

      -- keymap toggleterm "Esc" and ":" keys to go command line
      vim.keymap.set("t", "<Esc>", [[<C-\><C-n>k]], { noremap = true, buffer = t.bufnr })
      vim.keymap.set("n", "<Esc>", [[<C-\><C-n>a]], { noremap = true, buffer = t.bufnr })
      vim.keymap.set("n", "<C-c>", [[<C-\><C-n>a<C-c>]], { noremap = true, buffer = t.bufnr })
      vim.keymap.set("t", ":", [[<C-\><C-n>:]], { noremap = true, buffer = t.bufnr })
      vim.keymap.set("n", ":", [[<C-\><C-n>:]], { noremap = true, buffer = t.bufnr })

      vim.api.nvim_create_autocmd("BufEnter", {
        group = platformio,
        desc = "toggleterm buffer entered",
        buffer = t.bufnr,
        callback = function()
          setMode("terminal")
        end,
      })

      vim.api.nvim_create_autocmd("BufUnload", {
        group = platformio,
        desc = "toggleterm buffer unloaded",
        buffer = t.bufnr,
        callback = function(args)
          vim.keymap.del({ "n", "t" }, ":", { buffer = args.buf })
          vim.keymap.del({ "n", "t" }, "<Esc>", { buffer = args.buf })

          vim.keymap.del("n", "<C-c>", { buffer = args.buf })
          vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { noremap = true, buffer = 0 })

          -- clear autommmand when quit
          vim.api.nvim_clear_autocmds({ group = "platformio" })
        end,
      })

      vim.api.nvim_create_autocmd("WinClosed", {
        group = platformio,
        desc = "shutdown terminl",
        buffer = t.bufnr,
        callback = function()
          if vim.api.nvim_get_mode().mode == "nt" then
            setMode("terminal")
          end
          if t.id == 1 then -- non monitor terminal
            local enter = vim.api.nvim_replace_termcodes("<Enter>", true, false, true)
            vim.api.nvim_feedkeys("exit" .. enter, "x", false)
            -- vim.api.nvim_echo({ { 'WExit Pio_CLI!', 'MoreMsg' } }, true, {})
          elseif t.id == 2 then -- monitor terminal
            local ctrl_c = vim.api.nvim_replace_termcodes("<C-C>", true, true, true)
            vim.api.nvim_feedkeys(ctrl_c, "x", false)
            -- vim.api.nvim_echo({ { 'WExit Pio_Monitor!', 'MoreMsg' } }, true, {})
          end

          -- close terminal window
          vim.api.nvim_win_close(t.window, true)

          -- go back to previous window
          if origin_window and vim.api.nvim_win_is_valid(origin_window) then
            vim.api.nvim_set_current_win(origin_window)
          end
          setMode("normal")

          -- delete terminal buffer
          vim.api.nvim_buf_delete(t.bufnr, { force = true })
        end,
      })

      vim.api.nvim_create_autocmd("QuitPre", {
        group = platformio,
        desc = "shutdown terminl",
        buffer = t.bufnr,
        callback = function()
          if vim.api.nvim_get_mode().mode == "nt" then
            setMode("terminal")
          end
          if t.id == 1 then -- non monitor terminal
            local enter = vim.api.nvim_replace_termcodes("<Enter>", true, false, true)
            vim.api.nvim_feedkeys("exit" .. enter, "x", false)
            -- vim.api.nvim_echo({ { 'QExit Pio_CLI!', 'MoreMsg' } }, true, {})
          elseif t.id == 2 then -- monitor terminal
            local ctrl_c = vim.api.nvim_replace_termcodes("<C-C>", true, true, true)
            vim.api.nvim_feedkeys(ctrl_c, "x", false)
            -- vim.api.nvim_echo({ { 'QExit Pio_Monitor!', 'MoreMsg' } }, true, {})
          end

          -- close terminal window
          vim.api.nvim_win_close(t.window, true)

          -- go back to previous window
          if origin_window and vim.api.nvim_win_is_valid(origin_window) then
            vim.api.nvim_set_current_win(origin_window)
          end
          setMode("normal")

          -- delete terminal buffer
          vim.api.nvim_buf_delete(t.bufnr, { force = true })
        end,
      })

      vim.api.nvim_create_autocmd("ModeChanged", {
        desc = 'force terminal buffer to enter "t" mode; after entering "nt" mode comming back from command line mode',
        group = platformio,
        -- `:h mode()`
        -- `c` means `command-line editing`
        -- `nt` means `normal terminal mode`
        pattern = { "c*:nt*" },
        callback = function()
          setMode("terminal")
        end,
      })
    end,
  }
  -----termConfig: end terminal configuration table-----
  ------------------------------------------------------

  origin_window = vim.api.nvim_get_current_win()

  -- to have PIO Cli terminal without running any command, omit the 'cmd' option in termConfig table
  if command and command ~= "" then -- check if command string is not empty,
    termConfig.cmd = command        -- add cmd to the setup table of toggleterm
  end
  local terminal = require("toggleterm.terminal").Terminal:new(termConfig)
  terminal:toggle()
end

local is_windows = jit.os == "Windows"
--
M.devNul = is_windows and " 2>./nul" or " 2>/dev/null"
M.enter = is_windows and "\r" or "\n"
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

function M.get_pioini_path()
  for _, path in pairs(paths) do
    if M.file_exists(path .. "/platformio.ini") then
      return path
    end
  end
end

function M.cd_pioini()
  vim.cmd("cd " .. M.get_pioini_path())
end

function M.pio_install_check()
  local handel = (jit.os == "Windows") and assert(io.popen("where.exe pio 2>./nul")) or
  assert(io.popen("which pio 2>/dev/null"))
  local pio_path = assert(handel:read("*a"))
  handel:close()

  if #pio_path == 0 then
    vim.notify("Platformio not found in the path", vim.log.levels.ERROR)
    return false
  end
  return true
end

return M
