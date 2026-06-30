local M = {}

local config = require('platformio').config

local function load_backend(name)
    local ok, backend = pcall(require, 'platformio.pickers.' .. name)
    if ok then
        return backend
    end
    return nil
end

local function get_backend()
    local backend_name = config.picker_backend or 'auto'

    if backend_name == 'telescope' then
        return load_backend('telescope') or load_backend('ui_select')
    end

    if backend_name == 'ui_select' then
        return load_backend('ui_select')
    end

    return load_backend('telescope') or load_backend('ui_select')
end

function M.pick_board(boards, on_select)
    local backend = get_backend()
    if not backend then
        vim.notify('No picker backend available for PlatformIO.', vim.log.levels.ERROR)
        return
    end
    backend.pick_board(boards, on_select)
end

function M.pick_framework(frameworks, on_select)
    local backend = get_backend()
    if not backend then
        vim.notify('No picker backend available for PlatformIO.', vim.log.levels.ERROR)
        return
    end
    backend.pick_framework(frameworks, on_select)
end

function M.pick_library(libraries, on_select)
    local backend = get_backend()
    if not backend then
        vim.notify('No picker backend available for PlatformIO.', vim.log.levels.ERROR)
        return
    end
    backend.pick_library(libraries, on_select)
end

function M.pick_terminal(terminals, on_select)
    local backend = get_backend()
    if not backend then
        vim.notify('No picker backend available for PlatformIO.', vim.log.levels.ERROR)
        return
    end
    backend.pick_terminal(terminals, on_select)
end

function M.pick_env(envs, on_select)
    local backend = get_backend()
    if not backend then
        vim.notify('No picker backend available for PlatformIO.', vim.log.levels.ERROR)
        return
    end
    backend.pick_env(envs, on_select)
end

return M
