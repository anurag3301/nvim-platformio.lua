local M = {}

local utils = require('platformio.utils')
local config = require('platformio').config

local function process_ccls()
    local f = io.open(".ccls", "rb") 
    if not f then 
        print(".ccls file not found")
        return
    end

    local compiler = f:read()
    local build_flags = {compiler}

    local flags_allowed = {"%", "-W", "-std"}


    for line in f:lines() do
        if #line == 0 or string.sub(line, 1, 1) == '#' then
            goto continue
        end

        if check_prefix(line, "-I") or check_prefix(line, "-D") then
            table.insert(build_flags, line)
        end
        if check_prefix(line, "%cpp") then
            splitted = strsplit(line, " ")
            for _, flag in ipairs(splitted) do
                for _, flag_check in ipairs(flags_allowed) do
                    if check_prefix(flag, flag_check) then
                        table.insert(build_flags, flag)
                    end 
                end
            end
        end
        
        ::continue::
    end

    f:close() 

    return build_flags
end

local function gen_compile_commands(build_flags)
    local cwd = vim.fn.getcwd()
    local build_cmd = "" 
    for _, flag in ipairs(build_flags) do
        build_cmd = build_cmd .. flag .. " " 
    end

    local entry = {{
        directory= cwd,
        file = vim.fs.joinpath(cwd, "src", "main.cpp"),
        command= build_cmd
    }}

    local f = io.open("compile_commands.json", "w") 
    f:write(vim.json.encode(entry, {indent="  ", sort_keys=true}))
    f:close()
end

function M.gen_clangd_config()
    local build_flags = process_ccls()
    gen_compile_commands(build_flags)
end


function M.piolsp()
  local command = 'pio project init --ide=vim'
  io.popen(command, "r"):close()

  if config.lsp == 'clangd' then
    M.gen_clangd_config()
  end
end

return M
