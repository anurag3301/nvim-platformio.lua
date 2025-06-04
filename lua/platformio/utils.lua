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

------------------------------------------------------
local is_windows = jit.os == "Windows"

M.devNul = is_windows and " 2>./nul" or " 2>/dev/null"

-- INFO: get enter
function M.enter()
  local shell = vim.o.shell
  if is_windows then
    return vim.fn.executable("pwsh") and "\r" or "\r\n"
  elseif shell:find("nu") then
    return "\r"
  else
    return "\n"
  end
end

-- INFO: set mode
local function setMode(target_mode)
  if target_mode == "n" or target_mode == "nt" or target_mode == "normal" or target_mode == "normal_terminal" then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
  elseif target_mode == "i" or target_mode == "t" or target_mode == "insert" or target_mode == "terminal" then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("i", true, false, true), "n", true)
  elseif target_mode == "v" or target_mode == "visual" then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("v", true, false, true), "n", true)
  elseif target_mode == "V" or target_mode == "visual_line" then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("V", true, false, true), "n", true)
  elseif target_mode == ":" or target_mode == "command_line" then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(":", true, false, true), "n", true)
  else
    vim.api.nvim_echo({ { "Error: Unknown target mode '" .. target_mode .. "'", "ErrorMsg" } }, true, {})
    return
  end
end

-- INFO: get previous window
local function getPreviousWindow(orig_window)
  local prev = {
    orig_window = orig_window,
    term = nil, --active terminal
    cli = nil, --cli terminal
    mon = nil, --mon terminal
    float = false, --is active terminal direction float
  }
  local terms = require("toggleterm.terminal").get_all(true)
  if #terms ~= 0 then
    for i = 1, #terms do
      local name_splt = M.strsplit(terms[i].display_name, ":")
      if name_splt[1] == "piocli" then
        prev.cli = terms[i]
        if terms[i].window == orig_window then
          ---@diagnostic disable-next-line: cast-local-type
          prev.orig_window = tonumber(name_splt[2]) -- set orig_window to the previous terminal onrig_window
          prev.term = terms[i]
        end
        if terms[i].direction == "float" then
          prev.float = true
        end
      elseif name_splt[1] == "piomon" then
        prev.mon = terms[i]
        if terms[i].window == orig_window then
          ---@diagnostic disable-next-line: cast-local-type
          prev.orig_window = tonumber(name_splt[2]) -- set orig_window to the previous terminal onrig_window
          prev.term = terms[i]
        end
        if terms[i].direction == "float" then
          prev.float = true
        end
      end
    end
  end
  return prev
end
------------------------------------------------------
-- INFO: Send command
local function send(term, cmd)
  vim.fn.chansend(term.job_id, cmd .. M.enter())
  if vim.api.nvim_buf_is_loaded(term.bufnr) and vim.api.nvim_buf_is_valid(term.bufnr) then
    if term.window and vim.api.nvim_win_is_valid(term.window) then --vim.ui.term_has_open_win(term) then
      vim.api.nvim_buf_call(term.bufnr, function()
        local mode = vim.api.nvim_get_mode().mode
        if mode == "n" or mode == "nt" then
          vim.cmd("normal! G") -- normal command to Goto bottom of buffer
        end
      end)
      vim.api.nvim_set_current_win(term.window) -- terminal focus
    end
  end
end
------------------------------------------------------
-- INFO: Quit
vim.api.nvim_create_user_command("PioTermQuit", function(_)
  local terms = require("toggleterm.terminal").get_all(true) --INFO: get all terminals
  local current_win_id = vim.api.nvim_get_current_win()
  if #terms ~= 0 then
    for i = 1, #terms do
      local name_splt = M.strsplit(terms[i].display_name, ":")
      if current_win_id == terms[i].window and name_splt[1]:find("pio", 1) then
        -- local mode = vim.api.nvim_get_mode().mode
        -- if mode ~= "t" then
        --   setMode("terminal", "Quit0")
        --   mode = vim.api.nvim_get_mode().mode
        -- end
        if name_splt[1] == "piomon" then -- monitor terminal
          local exit = vim.api.nvim_replace_termcodes("<C-C>exit", true, true, true)
          send(terms[i], exit)
        else -- cli terminal
          send(terms[i], "exit")
        end

        -- close terminal window
        vim.api.nvim_win_close(terms[i].window, true)

        -- go back to previous window
        local orig_window = tonumber(name_splt[2])
        if orig_window and vim.api.nvim_win_is_valid(orig_window) then
          vim.api.nvim_set_current_win(orig_window)
        else
          vim.api.nvim_set_current_win(0)
        end

        -- delete terminal buffer
        if vim.api.nvim_buf_is_valid(terms[i].bufnr) then
          vim.api.nvim_buf_delete(terms[i].bufnr, { force = true, unload = true })
        end

        setMode("normal")
        break
      end
    end
  end
end, {})
------------------------------------------------------

-- NOTE: Please ensure you have set hidden=true in your neovim config,
-- otherwise the terminals will be discarded when closed.
------------------------------------------------------
function M.ToggleTerminal(command, direction)
  ------------------------------------------------------
  local status_ok, _ = pcall(require, "toggleterm")
  if not status_ok then
    vim.api.nvim_echo({ { "toggleterm not found!", "ErrorMsg" } }, true, {})
    return
  end
  ------------------------------------------------------
  local title = ""
  local poiOpts = {}
  -- INFO: set orig_window to current window or if available get current toggleterm previous window
  local prev = getPreviousWindow(vim.api.nvim_get_current_win())
  local orig_window = prev.orig_window

  if string.find(command, " monitor") then
    if prev.mon then -- INFO: if previous monitor terminal already opened ==> reopen
      local win_type = vim.fn.win_gettype(prev.mon.window)
      local win_open = win_type == "" or win_type == "popup"
      if prev.mon.window and (win_open and vim.api.nvim_win_get_buf(prev.mon.window) == prev.mon.bufnr) then
        vim.api.nvim_set_current_win(prev.mon.window)
      else
        prev.mon:open()
      end
      return
    end
    title = "Pio Monitor: [In normal mode press: q to hide; :q to quit; :PioTermList to list terminals]"
    poiOpts.display_name = "piomon:" .. orig_window
  else -- INFO: if previous cli terminal already opened ==> reopen
    if prev.cli then
      local win_type = vim.fn.win_gettype(prev.cli.window)
      local win_open = win_type == "" or win_type == "popup"
      if prev.cli.window and (win_open and vim.api.nvim_win_get_buf(prev.cli.window) == prev.cli.bufnr) then
        vim.api.nvim_set_current_win(prev.cli.window)
      else
        prev.cli:open()
      end
      vim.defer_fn(function()
        if command and command ~= "" then
          send(prev.cli, command)
        end
      end, 50) -- 50ms delay, adjust as needed
      return
    end
    title = "Pio CLI> [In normal mode press: q to hide; :q to quit; :PioTermList to list terminals]"
    poiOpts.display_name = "piocli:" .. orig_window
  end
  poiOpts.direction = direction
  ------------------------------------------------------

  -- INFO: termConfig table start
  local termConfig = {
    hidden = true, -- Start hidden, we'll open it explicitly
    hide_numbers = true,
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

    -- INFO: on_open()
    on_open = function(t)
      -- Get properties of the 'Normal' highlight group (background of main editor)
      -- local hl = vim.api.nvim_get_hl(0, { name = "PmenuSel" })
      -- local hl = { bg = "#e4cf0e", fg = "#0012d9" }
      local hl = { bg = "#80a3d4", fg = "#000000" }

      if hl then
        vim.api.nvim_set_hl(0, "MyWinBar", { bg = hl.bg, fg = hl.fg })

        local winBartitle = "%#MyWinBar#" .. title .. "%*"
        vim.api.nvim_set_option_value("winbar", winBartitle, { scope = "local", win = t.window })

        -- Following necessary to solve that some time winbar not showing
        vim.schedule(function()
          vim.api.nvim_set_option_value("winbar", winBartitle, { scope = "local", win = t.window })
        end)
      end

      vim.keymap.set("t", "<Esc>", [[<C-\><C-n>k]], { noremap = true, buffer = t.bufnr })
      vim.keymap.set("n", "<Esc>", [[<C-\><C-n>a]], { noremap = true, buffer = t.bufnr })
      vim.keymap.set("c", "q", [[<cmd>PioTermQuit<CR>]], { desc = "PioTermQuit", noremap = true, buffer = t.bufnr })
      vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = t.bufnr, noremap = true, silent = true })

      local name_splt = M.strsplit(t.display_name, ":")
      vim.api.nvim_echo({
        { "ToggleTerm ", "MoreMsg" },
        { "(Term name: " .. name_splt[1] .. ")", "MoreMsg" },
        { "(Prev win ID: " .. name_splt[2] .. ")", "MoreMsg" },
        { "(Term Win ID: " .. t.window .. ")", "MoreMsg" },
        { "(Term Buffer#: " .. t.bufnr .. ")", "MoreMsg" },
        { "(Term id: " .. t.id .. ")", "MoreMsg" },
        { "(Job ID: " .. t.job_id .. ")", "MoreMsg" },
      }, true, {})
    end,

    -- INFO: on_close()
    on_close = function(t)
      orig_window = tonumber(M.strsplit(t.display_name, ":")[2])
      ---@diagnostic disable-next-line: param-type-mismatch
      if orig_window and vim.api.nvim_win_is_valid(orig_window) then
        vim.api.nvim_set_current_win(orig_window)
      else
        vim.api.nvim_set_current_win(0)
      end
      setMode("normal")
    end,

    -- INFO: on_create() {
    on_create = function(t)
      local platformio = vim.api.nvim_create_augroup("platformio", { clear = true })

      -- BufEnter
      vim.api.nvim_create_autocmd("BufEnter", {
        group = platformio,
        desc = "toggleterm buffer entered",
        buffer = t.bufnr,
        callback = function()
          local mode = vim.api.nvim_get_mode().mode
          if mode ~= "t" then
            setMode("terminal")
          end
        end,
      })

      -- BufLeave
      vim.api.nvim_create_autocmd("BufLeave", {
        group = platformio,
        desc = "toggleterm buffer entered",
        buffer = t.bufnr,
        callback = function()
          setMode("normal")
        end,
      })

      -- BufUnload
      vim.api.nvim_create_autocmd("BufUnload", {
        group = platformio,
        desc = "toggleterm buffer unloaded",
        buffer = t.bufnr,
        callback = function(args)
          vim.keymap.del("t", "<Esc>", { buffer = args.buf })
          vim.keymap.del("n", "<Esc>", { buffer = args.buf })
          vim.keymap.del("c", "q", { buffer = args.buf })
          vim.keymap.del("n", "q", { buffer = args.buf })

          vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { noremap = true, buffer = 0 })

          -- clear autommmand when quit
          vim.api.nvim_clear_autocmds({ group = "platformio" })
          setMode("normal")
        end,
      })
    end,
    -- INFO: on_create() }
  }
  -- INFO: termConfig table end

  termConfig = vim.tbl_deep_extend("force", termConfig, poiOpts or {})
  ------------------------------------------------------

  -- INFO: create new terminal
  local terminal = require("toggleterm.terminal").Terminal:new(termConfig)
  if prev.term and prev.float then
    prev.term:close()
  end
  terminal:toggle()
  vim.defer_fn(function()
    if command and command ~= "" then
      send(terminal, command)
    end
  end, 50) -- 50ms delay, adjust as needed sgget
end

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
  local handel = (jit.os == "Windows") and assert(io.popen("where.exe pio 2>./nul")) or assert(io.popen("which pio 2>/dev/null"))
  local pio_path = assert(handel:read("*a"))
  handel:close()

  if #pio_path == 0 then
    vim.notify("Platformio not found in the path", vim.log.levels.ERROR)
    return false
  end
  return true
end

return M
