local utils = require('platformio.utils')
local picker = require('platformio.pickers')
local M = {
  default_env = 'none',
}
local config = require('platformio').config

--- changes symlink if feasible.
function M.change_compiledb_symlink(env)
  local pathsep = '/'
  if utils.is_windows then
    pathsep = '\\'
  end
  if M.default_env == 'none' then
    vim.notify('compiledb does not exist for env ' .. M.default_env, vim.log.levels.ERROR, opts)
    return
  end
  utils.cd_pioini()
  local compile_commands_filename = 'compile_commands.json'
  local compile_commands_path = '.pio' .. pathsep .. 'build' .. pathsep .. M.default_env .. pathsep .. compile_commands_filename
  if not utils.file_exists(compile_commands_path) then
    vim.notify(compile_commands_path .. ' does not exist to link it', vim.log.levels.ERROR, opts)
    return
  end
  if utils.file_exists(compile_commands_filename) then
    if not os.remove(compile_commands_filename) then
      vim.notify(compile_commands_filename .. ' did not get removed', vim.log.levels.ERROR)
      return
    end
  end
  if config.clangd_source == 'compiledb' and utils.file_exists(compile_commands_path) then
    if utils.is_windows then
      os.execute('mklink ' .. compile_commands_filename .. ' ' .. compile_commands_path)
    else
      os.execute('ln -s ' .. compile_commands_path)
    end
  end
end

function M.pioenv()
  --- @type vim.log.levels
  local loglevel = vim.log.levels.INFO
  utils.cd_pioini()

  local cmd
  -- TODO: execute target list command
  if utils.is_windows then
    cmd = 'pio run --list-targets'
  else
    cmd = 'grep -F "[env:" < platformio.ini | sed "s/\\[env://" | sed "s/\\]//"'
  end
  --- @type file*?
  local stdio_stream
  stdio_stream, _ = io.popen(cmd, 'r')
  -- TODO: error checking
  if not stdio_stream then
    vim.notify('opening stdio or executing the cmd ' .. cmd .. 'failed', vim.log.levels.ERROR)
    return
  end

  io.input(stdio_stream)
  -- vim.notify(io.read('*a'), vim.log.levels.INFO)

  -- table layout:
  -- table header
  -- ----------------------
  -- env_name_without_spaces      some garbage
  --
  -- env_name_without_spaces      some garbage
  -- ...

  -- discard the first few lines, since they are just table headers and decorators
  -- _ = stdio_stream.read(stdio_stream, '*l')
  -- _ = stdio_stream.read(stdio_stream, '*l')

  --- @type string[]
  local envs = {}
  --- @type integer | nil
  local env_name_end
  if utils.is_windows then
    _ = stdio_stream.read(stdio_stream, '*line')
    _ = stdio_stream.read(stdio_stream, '*line')
  end
  for line in stdio_stream.lines(stdio_stream, '*l') do -- readmode is for the output of lines as var `line`
    if utils.is_windows then
      env_name_end, _ = string.find(line, ' ', 2) -- if cmd succeeds, the env name has to be at least 1 char long and contains no spaces. skip the first one and search for space
      env_name_end = env_name_end - 1
      if env_name_end then -- would start at 1, regardless of start index, so we don't need to differentiate between 0 and nil
        table.insert(envs, string.sub(line, 1, env_name_end))
      else
        vim.notify('formatting pio output failed on finding the first space char', vim.log.levels.ERROR)
        io.close(stdio_stream)
        return
      end
      _ = stdio_stream.read(stdio_stream, '*line')
    else
      table.insert(envs, line)
    end
  end

  table.insert(envs, 'none')
  io.close(stdio_stream)
  -- TODO: execute picker
  picker.pick_env(envs, function(selected_env)
    M.default_env = selected_env
    M.change_compiledb_symlink()
  end)
end

--- function to use for other modules to get the env flag
---@return string env_flag either an empty string, or a string with the flag
function M.get_flag()
  if M.default_env ~= 'none' then
    return ' -e ' .. M.default_env
  end
  return ''
end

--- function to determine if a pio-command accepts the env flag
---@param cmd string name of command that will be run
---@return boolean accepts_flag is true if cmd accepts the env flag
function M.command_accepts_flag(cmd)
  local true_table = {
    access = false,
    account = false,
    boards = false,
    check = true,
    ci = true,
    debug = true,
    device = false,
    home = false,
    org = false,
    pkg = false,
    project = false,
    remote = false,
    run = true,
    setting = false,
    system = false,
    team = false,
    test = true,
    upgrade = false,
  }
  return true_table[cmd]
end

return M
