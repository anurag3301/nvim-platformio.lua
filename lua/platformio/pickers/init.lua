local M = {}

local config = require('platformio').config

local AUTO_ORDER = { 'telescope', 'snacks', 'mini_pick', 'ui_select' }

local function load_backend(name)
  local ok, backend = pcall(require, 'platformio.pickers.' .. name)
  if ok then
    return backend
  end
  return nil
end

-- 'auto' tries backends in order and silently falls back; an explicit backend
-- name that isn't installed reports why and does not fall back to another one.
local function get_backend()
  local backend_name = config.picker_backend or 'auto'

  if backend_name == 'auto' then
    for _, name in ipairs(AUTO_ORDER) do
      local backend = load_backend(name)
      if backend then
        return backend
      end
    end
    vim.notify('No picker backend available for PlatformIO.', vim.log.levels.ERROR)
    return nil
  end

  local backend = load_backend(backend_name)
  if not backend then
    vim.notify(string.format('PlatformIO: picker backend "%s" is not installed.', backend_name), vim.log.levels.ERROR)
  end
  return backend
end

function M.pick_board(boards, on_select)
  local backend = get_backend()
  if backend then
    backend.pick_board(boards, on_select)
  end
end

function M.pick_framework(frameworks, on_select)
  local backend = get_backend()
  if backend then
    backend.pick_framework(frameworks, on_select)
  end
end

function M.pick_library(libraries, on_select)
  local backend = get_backend()
  if backend then
    backend.pick_library(libraries, on_select)
  end
end

function M.pick_terminal(terminals, on_select)
  local backend = get_backend()
  if backend then
    backend.pick_terminal(terminals, on_select)
  end
end

return M
