http = require("socket.http")
ltn12 = require("ltn12")

resp, r = {}, {}

url = 'https://api.registry.platformio.org/v3/search?query=%22ArduinoJson%22&page=1&limit=50'
args = {}

client, code, headers, status = http.request{url=url, sink=ltn12.sink.table(resp),
                                            method="GET"}


if (code == 200) then
    json_str = ""
    for k,v in pairs(resp) do
        json_str = json_str .. v
    end
    local json_data = require('lunajson').decode(json_str)
    local lib_name = {}
    local lib_data = {}

    for k,v in pairs(json_data['items']) do
        lib_data[v['name']] = v
        table.insert(lib_name, v['name'])
    end

    print(vim.inspect(lib_data))
end

