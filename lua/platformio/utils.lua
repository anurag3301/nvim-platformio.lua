local M = {}

-- M.extra = 'printf \"\\\\n\\\\033[0;33mPlease Press ENTER to continue \\\\033[0m\"; read'
M.extra = ' && echo . && echo . && echo Please Press ENTER to continue'

function M.strsplit(inputstr, del)
  local t = {}
  for str in string.gmatch(inputstr, '([^' .. del .. ']+)') do
    table.insert(t, str)
  end
  return t
end

local function pathmul(n)
  return '..' .. string.rep('/..', n)
end

----------------------------------------------------------------------------------------
local platformio = vim.api.nvim_create_augroup('platformio', { clear = true })
function M.ToggleTerminal(command, direction, title)
  --
  local Terminal = require('toggleterm.terminal').Terminal
  local terminal = Terminal:new {
    cmd = command,
    direction = direction,
    close_on_exit = false,

    on_open = function(t)
      --Only to set Piomon toggleterm winbar title/message
      if title then
        -- local hl = vim.api.nvim_get_hl(0, { name = "CurSearch" })
        local hl = { bg = '#e4cf0e', fg = '#0012d9' }
        vim.api.nvim_set_hl(0, 'MyWinBar', { bg = hl.bg, fg = hl.fg })

        local winBarTitle = '%#MyWinBar#' .. title .. '%*'
        vim.api.nvim_set_option_value('winbar', winBarTitle, { scope = 'local', win = t.window })

        -- Following necessary to solve that some time winbar not showing
        vim.schedule(function()
          vim.api.nvim_set_option_value('winbar', winBarTitle, { scope = 'local', win = t.window })
        end)
      end
    end,

    on_create = function(t)
      t.set_mode(t, 'i')
      --Only to set Piomon toggleterm winbar title/message
      if title then
        --set toggleterm to be in insert mode

        -- keymap toggleterm "Esc" and ":" keys to go command line
        vim.keymap.set('t', '<Esc>', [[<C-\><C-n>k]], { noremap = true, buffer = t.bufnr })
        vim.keymap.set('n', '<Esc>', [[<C-\><C-n>a]], { noremap = true, buffer = t.bufnr })
        vim.keymap.set('n', '<C-c>', [[<C-\><C-n>a<C-c>]], { noremap = true, buffer = t.bufnr })
        vim.keymap.set('t', ':', [[<C-\><C-n>:]], { noremap = true, buffer = t.bufnr })
        vim.keymap.set('n', ':', [[<C-\><C-n>:]], { noremap = true, buffer = t.bufnr })

        vim.api.nvim_create_autocmd('BufEnter', {
          group = platformio,
          desc = 'toggleterm buffer entered',
          buffer = t.bufnr,
          callback = function(args)
            t.set_mode(t, 'i')
          end,
        })

        vim.api.nvim_create_autocmd('BufUnload', {
          group = platformio,
          desc = 'toggleterm buffer unloaded',
          buffer = t.bufnr,
          callback = function(args)
            vim.keymap.del({ 'n', 't' }, ':', { buffer = args.buf })
            vim.keymap.del({ 'n', 't' }, '<Esc>', { buffer = args.buf })

            vim.keymap.del('n', '<C-c>', { buffer = args.buf })
            vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { noremap = true, buffer = 0 })

            -- clear autommmand when quit
            vim.api.nvim_clear_autocmds { group = 'platformio' }
          end,
        })

        vim.api.nvim_create_autocmd('QuitPre', {
          group = platformio,
          desc = 'shutdown terminl',
          buffer = t.bufnr,
          callback = function()
            vim.api.nvim_exec_autocmds('BufUnload', { group = platformio, buffer = t.bufnr, data = t.bufnr })
            -- do clean and proper toggleterm shutdown
            t.set_mode(t, 'n')
            t.shutdown(t)
          end,
        })

        vim.api.nvim_create_autocmd('ModeChanged', {
          -- Autocommand for modechanges of toggleterm buffer
          group = platformio,
          buffer = t.bufnr,
          callback = function()
            local old_mode = vim.v.event.old_mode
            local new_mode = vim.v.event.new_mode
            if new_mode == 'nt' and old_mode == 'c' then
              -- after entering normal terminal mode comming back from command line mode,
              -- below force terminal buffer to enter insert mode
              t.set_mode(t, 'i')
            end
          end,
        })
      end
    end,
  }
  terminal:toggle()
end

function M.TerminalOut(command)
  local width = vim.api.nvim_get_option_value('columns', {})
  local height = vim.api.nvim_get_option_value('lines', {})
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
    relative = 'win',
    border = { '╔', '═', '╗', '║', '╝', '═', '╚', '║' },
    width = win_width,
    style = 'minimal',
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
  vim.api.nvim_chan_send(chan, vim.fn.getcwd() .. ' > ' .. command .. '\r\n\r\n\r\n')
  --
  local opts = {
    pty = true,
    -- stdin = "pipe",
    on_stdout = function(_, data)
      vim.api.nvim_chan_send(chan, table.concat(data, '\r\n'))
    end,
    on_exit = function(_, exit_code)
      vim.api.nvim_chan_send(chan, '\r\n\r\n[Process exited ' .. tostring(exit_code) .. ']')
      vim.api.nvim_chan_send(chan, '\r\n\r\nPress <ENTER> to close this window.')
      vim.api.nvim_buf_set_keymap(bufnr, 'n', '<CR>', '<cmd>bd!<CR>', { noremap = true, silent = true })
    end,
  }
  -- Send the command to terminal
  jobid = vim.fn.jobstart(command, opts)
end

local is_windows = jit.os == 'Windows'
--
M.devNul = is_windows and ' 2>./nul' or ' 2>/dev/null'
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

function M.cd_pioini()
  for _, path in pairs(paths) do
    if M.file_exists(path .. '/platformio.ini') then
      vim.cmd('cd ' .. path)
      break
    end
  end
end

function M.pio_install_check()
  local handel = (jit.os == 'Windows') and assert(io.popen 'where.exe pio 2>./nul') or assert(io.popen 'which pio 2>/dev/null')
  local pio_path = assert(handel:read '*a')
  handel:close()

  if #pio_path == 0 then
    vim.notify('Platformio not found in the path', vim.log.levels.ERROR)
    return false
  end
  return true
end

return M
