
local M = {}
local default_config = {
  lsp = 'ccls',
  menu_key = nil,

  menu_bindings = {
    { group = '  [g]eneral', key = 'g', elements = {
      { key = 'b', cmd = 'run', desc = ' [b]uild' },
      { key = 'c', cmd = 'run -t clean', desc = ' [c]lean' },
      { key = 'f', cmd = 'run -t fullclean', desc = ' [f]ull clean' },
      { key = 'd', cmd = 'device list', desc = ' [d]evice list' },
      { key = 'm', cmd = 'run -t monitor', desc = ' [m]onitor' },
      { key = 'u', cmd = 'run -t upload', desc = ' [u]pload' },
      { key = 's', cmd = 'run -t uploadfs', desc = ' upload file [s]ystem' },
      { key = 't', cmd = '', desc = ' Core CLI [T]erminal' },
    }},
    { group = '  [d]ependencies', key = 'd', elements = {
      { key = 'l', cmd = 'pkg list', desc = ' [l]ist packages' },
      { key = 'o', cmd = 'pkg outdated', desc = ' List [o]utdated packages' },
      { key = 'u', cmd = 'pkg update', desc = ' [u]pdate packages' },
    }},
    { group = '  [a]dvance', key = 'a', elements = {
      { key = 't', cmd = 'test', desc = ' [t]est' },
      { key = 'c', cmd = 'check', desc = ' [c]heck' },
      { key = 'd', cmd = 'debug', desc = ' [d]ebug' },
      { key = 'b', cmd = 'run -t compiledb', desc = ' compilation data[b]ase' },
    }},
    { group = '  [v]erbose', key = 'av', elements = {
      { key = 'v', cmd = 'debug', desc = ' [v]erbose' },
      { key = 'b', cmd = 'run -v', desc = ' [b]uild' },
      { key = 'd', cmd = 'debug -v', desc = ' [d]ebug' },
      { key = 'u', cmd = 'run -v -t upload', desc = ' [u]pload' },
      { key = 's', cmd = 'run -v -t uploadfs', desc = ' upload file [s]ystem' },
      { key = 't', cmd = 'test -v', desc = ' [t]est' },
      { key = 'c', cmd = 'check -v', desc = ' [c]heck' },
      { key = 'a', cmd = 'run -v -t compiledb', desc = ' compilation databa[a]e' },
    }},
    { group = '  [r]emote', key = 'r', elements = {
      { key = 'u', cmd = 'remote run -t upload', desc = ' [u]pload' },
      { key = 't', cmd = 'remote test', desc = ' [t]est' },
      { key = 'm', cmd = 'remote run -t monitor', desc = ' [m]onitor' },
      { key = 'd', cmd = 'remote device list', desc = ' [d]evice list' },
    }},
    { group = '  [m]iscellaneous', key = 'm', elements = {
      { key = 'u', cmd = 'upgrade', desc = ' [u]pgrade' },
    }},
  }
}

M.config = vim.deepcopy(default_config)

function M.setup(user_config)
  local valid_keys = {
    lsp = true,
    menu_key = true,
    menu_bindings = true,
  }
  for key, _ in pairs(user_config or {}) do
    if not valid_keys[key] then
      local error_message = string.format("Invalid configuration key: '%s'\n%s", key, debug.traceback 'Stack trace:')
      vim.api.nvim_echo({ { error_message, 'ErrorMsg' } }, true, {}) -- replaced deprecated function
      return
    end
  end
  M.config = vim.tbl_deep_extend('force', default_config, user_config or {})
  require('platformio.piomenu').piomenu(M.config)
end

return M
