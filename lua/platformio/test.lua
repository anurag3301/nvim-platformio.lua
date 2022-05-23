local handel = io.popen('pio boards --json-output')
local json_str = handel:read("*a")
handel:close()

local json_data = require('lunajson').decode(json_str)
local board_name = {}

for i,v in pairs(json_data) do
    table.insert(board_name, v['name'])
end

for i,v in pairs(board_name) do
    print(v)
end
