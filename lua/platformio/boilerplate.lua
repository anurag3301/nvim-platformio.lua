local M = {}
local uv = vim.loop

local boilerplate = {}

boilerplate['arduino'] = {
  filename = 'main.cpp',
  content = [[
#include <Arduino.h>

void setup() {

}

void loop() {

}
]],
}

function M.boilerplate_gen(framework)
  local entry = boilerplate[framework]
  if not entry then
    return
  end

  local src_path = 'src'
  local stat = uv.fs_stat(src_path)

  if not stat or stat.type ~= 'directory' then
    return
  end

  local handle = uv.fs_scandir(src_path)
  if handle then
    while true do
      local name = uv.fs_scandir_next(handle)
      if not name then
        break
      end
      if name ~= '.' and name ~= '..' then
        return
      end
    end
  end

  local file_path = src_path .. '/' .. entry.filename
  local fd = uv.fs_open(file_path, 'w', 420)
  if not fd then
    return
  end

  uv.fs_write(fd, entry.content)
  uv.fs_close(fd)
end

return M
