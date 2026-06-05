local utils = require('platformio.utils')
local picker = require('platformio.pickers')
local M = {
  default_env = 'none',
}

function M.pioenv()
  --- @type vim.log.levels
  local loglevel = vim.log.levels.INFO
  if not utils.pio_install_check() then
    return
  end
  utils.cd_pioini()

  -- TODO: execute target list command
  local cmd = 'pio run --list-targets'
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
  _ = stdio_stream.read(stdio_stream, '*line')
  _ = stdio_stream.read(stdio_stream, '*line')
  for line in stdio_stream.lines(stdio_stream, '*l') do -- readmode is for the output of lines as var `line`
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
  end

  table.insert(envs, 'none')
  io.close(stdio_stream)
  -- TODO: execute picker
  picker.pick_env(envs, function(selected_env)
    M.default_env = selected_env
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
