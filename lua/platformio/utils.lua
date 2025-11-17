local M = {}

local config = require('platformio').config

-- M.extra = 'printf \'\\\\n\\\\033[0;33mPlease Press ENTER to continue \\\\033[0m\'; read'
M.extra = ' && echo . && echo . && echo Please Press ENTER to continue'

function M.strsplit(inputstr, del)
  local t = {}
  if type(inputstr) ~= "string" or type(inputstr) ~= "string" then
    return t
  end
  for str in string.gmatch(inputstr, '([^' .. del .. ']+)') do
    table.insert(t, str)
  end
  return t
end

function M.check_prefix(str, prefix)
  return str:sub(1, #prefix) == prefix
end

local function pathmul(n)
  return '..' .. string.rep('/..', n)
end

------------------------------------------------------
local is_windows = jit.os == 'Windows'

M.devNul = is_windows and ' 2>./nul' or ' 2>/dev/null'

-- INFO: get current OS enter
function M.enter()
  local shell = vim.o.shell
  if is_windows then
    return vim.fn.executable('pwsh') and '\r' or '\r\n'
  elseif shell:find('nu') then
    return '\r'
  else
    return '\n'
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
  local terms = require('toggleterm.terminal').get_all(true)
  if #terms ~= 0 then
    for i = 1, #terms do
      local name_splt = M.strsplit(terms[i].display_name, ':')
      if name_splt[1] == 'piocli' then
        prev.cli = terms[i]
        if terms[i].window == orig_window then
          ---@diagnostic disable-next-line: cast-local-type
          prev.orig_window = tonumber(name_splt[2]) -- set orig_window to the previous terminal onrig_window
          prev.term = terms[i]
        end
        if terms[i].direction == 'float' then
          prev.float = true
        end
      elseif name_splt[1] == 'piomon' then
        prev.mon = terms[i]
        if terms[i].window == orig_window then
          ---@diagnostic disable-next-line: cast-local-type
          prev.orig_window = tonumber(name_splt[2]) -- set orig_window to the previous terminal onrig_window
          prev.term = terms[i]
        end
        if terms[i].direction == 'float' then
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
      vim.api.nvim_set_current_win(term.window) -- terminal focus
      vim.api.nvim_buf_call(term.bufnr, function()
        local mode = vim.api.nvim_get_mode().mode
        if mode == 'n' or mode == 'nt' then
          vim.cmd('normal! G') -- normal command to Goto bottom of buffer (scroll)
        end
      end)
    end
  end
end

------------------------------------------------------
-- INFO: PioTermClose
local function PioTermClose(t)
  local orig_window = tonumber(M.strsplit(t.display_name, ':')[2])
  -- close terminal window
  vim.api.nvim_win_close(t.window, true)

  -- go back to previous window
  if orig_window and vim.api.nvim_win_is_valid(orig_window) then
    vim.api.nvim_set_current_win(orig_window)
  else
    vim.api.nvim_set_current_win(0)
  end
end

------------------------------------------------------
-- INFO: ToggleTerminal
function M.ToggleTerminal(command, direction, resetLSP)
  if resetLSP == nil then
    resetLSP = false
  end

  local status_ok, _ = pcall(require, 'toggleterm')
  if not status_ok then
    vim.api.nvim_echo({ { 'toggleterm not found!', 'ErrorMsg' } }, true, {})
    return
  end

  local title = ''
  local pioOpts = {}

  -- INFO: set orig_window to current window, or if available get current toggleterm previous window
  local prev = getPreviousWindow(vim.api.nvim_get_current_win())
  local orig_window = prev.orig_window

  if string.find(command, ' monitor') then
    if prev.mon then -- INFO: if previous monitor terminal already opened ==> reopen
      local win_type = vim.fn.win_gettype(prev.mon.window)
      local win_open = win_type == '' or win_type == 'popup'
      if prev.mon.window and (win_open and vim.api.nvim_win_get_buf(prev.mon.window) == prev.mon.bufnr) then
        vim.api.nvim_set_current_win(prev.mon.window)
      else
        prev.mon:open()
      end
      return
    end
    title = 'Pio Monitor: [In normal mode press: q or :q to hide; :q! to quit; :PioTermList to list terminals]'
    pioOpts.display_name = 'piomon:' .. orig_window
  else -- INFO: if previous cli terminal already opened ==> reopen
    if prev.cli then
      local win_type = vim.fn.win_gettype(prev.cli.window)
      local win_open = win_type == '' or win_type == 'popup'
      if prev.cli.window and (win_open and vim.api.nvim_win_get_buf(prev.cli.window) == prev.cli.bufnr) then
        vim.api.nvim_set_current_win(prev.cli.window)
      else
        prev.cli:open()
      end
      vim.defer_fn(function()
        if command and command ~= '' then
          send(prev.cli, command)
        end
      end, 50) -- 50ms delay, adjust as needed
      return
    end
    title = 'Pio CLI> [In normal mode press: q or :q to hide; :q! to quit; :PioTermList to list terminals]'
    pioOpts.display_name = 'piocli:' .. orig_window
  end
  pioOpts.direction = direction
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
        border = 'FloatBorder',
        background = 'NormalFloat',
      },
    },
    close_on_exit = false,

    -- INFO: on_open()
    on_open = function(t)
      -- Get properties of the 'Normal' highlight group (background of main editor)
      -- local hl = vim.api.nvim_get_hl(0, { name = 'PmenuSel' })
      -- local hl = { bg = '#e4cf0e', fg = '#0012d9' }
      local hl = { bg = '#80a3d4', fg = '#000000' }

      if hl then
        vim.api.nvim_set_hl(0, 'MyWinBar', { bg = hl.bg, fg = hl.fg })

        local winBartitle = '%#MyWinBar#' .. title .. '%*'
        vim.api.nvim_set_option_value('winbar', winBartitle, { scope = 'local', win = t.window })

        -- Following necessary to solve that some time winbar not showing
        vim.schedule(function()
          vim.api.nvim_set_option_value('winbar', winBartitle, { scope = 'local', win = t.window })
        end)
      end
      vim.keymap.set('t', '<Esc>', [[<C-\><C-n>k]], { buffer = t.bufnr })
      vim.keymap.set('n', '<Esc>', [[<C-\><C-n>a]], { buffer = t.bufnr })

      vim.keymap.set('n', 'q', function()
        PioTermClose(t)
      end, { desc = 'PioTermClose', buffer = t.bufnr })

      if config.debug then
      local name_splt = M.strsplit(t.display_name, ':')
        vim.api.nvim_echo({
          { 'ToggleTerm ', 'MoreMsg' },
          { '(Term name: ' .. name_splt[1] .. ')', 'MoreMsg' },
          { '(Prev win ID: ' .. name_splt[2] .. ')', 'MoreMsg' },
          { '(Term Win ID: ' .. t.window .. ')', 'MoreMsg' },
          { '(Term Buffer#: ' .. t.bufnr .. ')', 'MoreMsg' },
          { '(Term id: ' .. t.id .. ')', 'MoreMsg' },
          { '(Job ID: ' .. t.job_id .. ')', 'MoreMsg' },
        }, true, {})
      end
    end,

    -- INFO: on_close()
    on_close = function(t)
      orig_window = tonumber(M.strsplit(t.display_name, ':')[2])
      ---@diagnostic disable-next-line: param-type-mismatch
      if orig_window and vim.api.nvim_win_is_valid(orig_window) then
        vim.api.nvim_set_current_win(orig_window)
      else
        vim.api.nvim_set_current_win(0)
      end
      if resetLSP then
        vim.cmd(':PioLSP')
      end
    end,

    -- INFO: on_create() {
    on_create = function(t)
      local platformio = vim.api.nvim_create_augroup(M.strsplit(t.display_name, ':')[1], { clear = true })

      -- INFO: CmdlineLeave
      vim.api.nvim_create_autocmd('CmdlineLeave', {
        group = platformio,
        -- pattern = ':',
        buffer = t.bufnr,
        callback = function()
          if vim.v.event and not vim.v.event.abort and vim.v.event.cmdtype == ':' then
            local quit = vim.fn.getcmdline() == 'q'
            local quitbang = vim.fn.getcmdline() == 'q!'
            if quitbang or quit then
              local name_splt = M.strsplit(t.display_name, ':')
              if quitbang then
                if name_splt[1] == 'piomon' then -- monitor terminal
                  local exit = vim.api.nvim_replace_termcodes('<C-C>exit', true, true, true)
                  send(t, exit)
                else -- cli terminal
                  send(t, 'exit')
                end
              end

              orig_window = tonumber(name_splt[2])
              vim.schedule(function()
                -- go back to previous window
                if orig_window and vim.api.nvim_win_is_valid(orig_window) then
                  vim.api.nvim_set_current_win(orig_window)
                else
                  vim.api.nvim_set_current_win(0)
                end
              end)
            end
          end
        end,
      })

      -- INFO: BufUnload
      vim.api.nvim_create_autocmd('BufUnload', {
        group = platformio,
        desc = 'toggleterm buffer unloaded',
        buffer = t.bufnr,
        callback = function(args)
          vim.keymap.del('t', '<Esc>', { buffer = args.buf })
          vim.keymap.del('n', '<Esc>', { buffer = args.buf })

          -- clear autommmand when quit
          vim.api.nvim_clear_autocmds({ group = M.strsplit(t.display_name, ':')[1] })
        end,
      })
    end,
  }
  -- INFO: termConfig table end

  termConfig = vim.tbl_deep_extend('force', termConfig, pioOpts or {})

  -- INFO: create new terminal
  local terminal = require('toggleterm.terminal').Terminal:new(termConfig)
  if prev.term and prev.float then
    prev.term:close()
  end
  terminal:toggle()
  vim.defer_fn(function()
    if command and command ~= '' then
      send(terminal, command)
    end
  end, 50) -- 50ms delay, adjust as needed sgget
end

----------------------------------------------------------------------------------------

local paths = { '.', '..', pathmul(1), pathmul(2), pathmul(3), pathmul(4), pathmul(5) }

function M.file_exists(name)
  local f = io.open(name, 'r')
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

function M.get_pioini_path()
  for _, path in pairs(paths) do
    if M.file_exists(path .. '/platformio.ini') then
      return path
    end
  end
end

function M.cd_pioini()
  if vim.g.platformioRootDir ~= nil then
    vim.cmd('cd ' .. vim.g.platformioRootDir)
  else
    vim.cmd('cd ' .. M.get_pioini_path())
  end
end

function M.pio_install_check()
  local handel = (jit.os == 'Windows') and assert(io.popen('where.exe pio 2>./nul')) or assert(io.popen('which pio 2>/dev/null'))
  local pio_path = assert(handel:read('*a'))
  handel:close()

  if #pio_path == 0 then
    vim.notify('Platformio not found in the path', vim.log.levels.ERROR)
    return false
  end
  return true
end

function M.async_shell_cmd(cmd, callback)
  local output = {}

  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    stderr_buffered = false,

    on_stdout = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= '' then
            table.insert(output, line)
          end
        end
      end
    end,

    on_exit = function(_, code)
      callback(output, code)
    end,
  })
end

return M
