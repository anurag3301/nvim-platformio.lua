local M = {}

-- M.extra = 'printf \'\\\\n\\\\033[0;33mPlease Press ENTER to continue \\\\033[0m\'; read'
M.extra = ' && echo . && echo . && echo Please Press ENTER to continue'

function M.strsplit(inputstr, del)
  local t = {}
  if type(inputstr) == 'string' and inputstr and inputstr ~= '' then
    for str in string.gmatch(inputstr, '([^' .. del .. ']+)') do
      table.insert(t, str)
    end
  end
  return t
end

function M.check_prefix(str, prefix)
  return str:sub(1, #prefix) == prefix
end

function M.sanitize_shell_arg(str)
  return (str or ''):gsub('[^%w%.%-_/]', '')
end

------------------------------------------------------
M.is_windows = jit.os == 'Windows'

M.devNul = M.is_windows and ' 2>./nul' or ' 2>/dev/null'

----------------------------------------------------------------------------------------

function M.file_exists(name)
  local f = io.open(name, 'r')
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

function M.get_platformioRootDir()
  if vim.g.platformioRootDir == nil then
    local path = vim.api.nvim_buf_get_name(0)
    if path == '' then
      path = vim.fn.getcwd()
    end
    local match = vim.fs.find({ 'platformio.ini' }, { upward = true, path = path })
    if #match > 0 then
      vim.g.platformioRootDir = vim.fs.dirname(match[1])
    end

    if vim.g.platformioRootDir == nil then
      vim.notify('Could not find platformio.ini, run :Pioinit to create a new project', vim.log.levels.ERROR)
    end
  end
  return vim.g.platformioRootDir
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

function M.shell_cmd_blocking(args, working_dir)
  if vim.system then
    local ok, res = pcall(function()
      return vim.system(args, { cwd = working_dir, text = true }):wait()
    end)
    if not ok then
      return nil, 'failed to spawn command: ' .. tostring(res)
    end
    return res.stdout
  else
    -- Fallback for Neovim < 0.10.0 using vim.fn.system
    local cmd_str = table.concat(args, ' ')
    local old_dir = nil
    if working_dir then
      old_dir = vim.fn.getcwd()
      vim.cmd('cd ' .. vim.fn.fnameescape(working_dir))
    end

    local stdout = vim.fn.system(cmd_str)

    if old_dir then
      vim.cmd('cd ' .. vim.fn.fnameescape(old_dir))
    end

    return stdout
  end
end

return M
