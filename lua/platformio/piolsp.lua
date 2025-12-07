local M = {}

local utils = require('platformio.utils')
local config = require('platformio').config

local function escape_flags(flags)
  local escaped_flags = {}

  for _, flag in ipairs(flags) do
    local escaped = flag
    escaped = escaped:gsub('\\', '\\\\') -- Escape backslashes first
    escaped = escaped:gsub('"', '\\"') -- Escape double quotes (for -D macros)
    -- Escape parentheses (common in include paths)
    escaped = escaped:gsub('%(', '\\(')
    escaped = escaped:gsub('%)', '\\)')
    table.insert(escaped_flags, escaped)
  end

  return escaped_flags
end

local function process_ccls()
  local flags_allowed = { '%', '-W', '-std' }

  local f = io.open(vim.fs.joinpath(vim.g.platformioRootDir, '.ccls'), 'rb')
  if not f then
    vim.notify('.ccls file not found', vim.log.levels.ERROR)
    return {}
  end

  local compiler = f:read()
  local build_flags = { compiler }

  for line in f:lines() do
    if #line == 0 or string.sub(line, 1, 1) == '#' then
      goto continue
    end

    if utils.check_prefix(line, '-I') or utils.check_prefix(line, '-D') then
      table.insert(build_flags, line)
    end
    if utils.check_prefix(line, '%cpp') then
      splitted = utils.strsplit(line, ' ')
      for _, flag in ipairs(splitted) do
        for _, flag_check in ipairs(flags_allowed) do
          if utils.check_prefix(flag, flag_check) then
            table.insert(build_flags, flag)
          end
        end
      end
    end

    ::continue::
  end

  f:close()

  return escape_flags(build_flags)
end

local function gen_compile_commands(build_flags)
  local project_root = vim.g.platformioRootDir
  local build_cmd = ''
  for _, flag in ipairs(build_flags) do
    build_cmd = build_cmd .. flag .. ' '
  end

  local entry = { {
    directory = project_root,
    file = vim.fs.joinpath(project_root, 'src', 'main.cpp'),
    command = build_cmd,
  } }

  local f = io.open(vim.fs.joinpath(project_root, 'compile_commands.json'), 'w')
  f:write(vim.json.encode(entry, { indent = '  ', sort_keys = true }))
  f:close()
end

local function gitignore_lsp_configs(config_file)
  local gitignore_path = vim.fs.joinpath(vim.g.platformioRootDir, '.gitignore')
  local file = io.open(gitignore_path, 'r')
  local pattern = '^%s*' .. vim.pesc(config_file) .. '%s*$'

  if file then
    for line in file:lines() do
      if line:match(pattern) then
        file:close()
        return
      end
    end
    file:close()
  end

  file = io.open(gitignore_path, 'a')
  file:write(config_file .. '\n')
  file:close()
end

function M.gen_clangd_config()
  local build_flags = process_ccls()
  gen_compile_commands(build_flags)
end

function M.piolsp()
  if not utils.pio_install_check() then
    return
  end
  if config.lsp == 'clangd' and config.clangd_source == 'compiledb' then
    utils.shell_cmd_blocking('pio run -t compiledb')
    gitignore_lsp_configs('compile_commands.json')
  else
    utils.shell_cmd_blocking('pio project init --ide=vim')

    if config.lsp == 'clangd' then
      M.gen_clangd_config()
      gitignore_lsp_configs('compile_commands.json')
      os.remove(vim.fs.joinpath(vim.g.platformioRootDir, '.ccls'))
    else
      gitignore_lsp_configs('.ccls')
    end
  end
  vim.notify('LSP config generation completed!', vim.log.levels.INFO)
  vim.cmd('LspRestart')
end

return M
