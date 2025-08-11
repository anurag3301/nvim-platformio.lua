local M = {}
M.config = {
  lsp = 'ccls',
  menu_key = nil,
  menu_name = 'PlatformIO',

  menu_bindings = {
    { node = 'item', desc = '[L]ist terminals',    shortcut = 'l', command = 'PioTermList' },
    { node = 'item', desc = '[T]erminal Core CLI', shortcut = 't', command = 'Piocmdf' },
    {
      node = 'menu',
      desc = '[G]eneral',
      shortcut = 'g',
      items = {
        { node = 'item', desc = '[B]uild',       shortcut = 'b', command = 'Piocmdf run' },
        { node = 'item', desc = '[U]pload',      shortcut = 'u', command = 'Piocmdf run -t upload' },
        { node = 'item', desc = '[M]onitor',     shortcut = 'm', command = 'Piocmdh run -t monitor' },
        { node = 'item', desc = '[C]lean',       shortcut = 'c', command = 'Piocmdf run -t clean' },
        { node = 'item', desc = '[F]ull clean',  shortcut = 'f', command = 'Piocmdf run -t fullclean' },
        { node = 'item', desc = '[D]evice list', shortcut = 'd', command = 'Piocmdf device list' },
      },
    },
    {
      node = 'menu',
      desc = '[P]latform',
      shortcut = 'p',
      items = {
        { node = 'item', desc = '[B]uild file system',  shortcut = 'b', command = 'Piocmdf run -t buildfs' },
        { node = 'item', desc = 'Program [S]ize',       shortcut = 's', command = 'Piocmdf run -t size' },
        { node = 'item', desc = '[U]pload file system', shortcut = 'u', command = 'Piocmdf run -t uploadfs' },
        { node = 'item', desc = '[E]rase Flash',        shortcut = 'e', command = 'Piocmdf run -t erase' },
      },
    },
    {
      node = 'menu',
      desc = '[D]ependencies',
      shortcut = 'd',
      items = {
        { node = 'item', desc = '[L]ist packages',     shortcut = 'l', command = 'Piocmdf pkg list' },
        { node = 'item', desc = '[O]utdated packages', shortcut = 'o', command = 'Piocmdf pkg outdated' },
        { node = 'item', desc = '[U]pdate packages',   shortcut = 'u', command = 'Piocmdf pkg update' },
      },
    },
    {
      node = 'menu',
      desc = '[A]dvanced',
      shortcut = 'a',
      items = {
        { node = 'item', desc = '[T]est',                 shortcut = 't', command = 'Piocmdf test' },
        { node = 'item', desc = '[C]heck',                shortcut = 'c', command = 'Piocmdf check' },
        { node = 'item', desc = '[D]ebug',                shortcut = 'd', command = 'Piocmdf debug' },
        { node = 'item', desc = 'Compilation Data[b]ase', shortcut = 'b', command = 'Piocmdf run -t compiledb' },
        {
          node = 'menu',
          desc = '[V]erbose',
          shortcut = 'v',
          items = {
            { node = 'item', desc = 'Verbose [B]uild',  shortcut = 'b', command = 'Piocmdf run -v' },
            { node = 'item', desc = 'Verbose [U]pload', shortcut = 'u', command = 'Piocmdf run -v -t upload' },
            { node = 'item', desc = 'Verbose [T]est',   shortcut = 't', command = 'Piocmdf test -v' },
            { node = 'item', desc = 'Verbose [C]heck',  shortcut = 'c', command = 'Piocmdf check -v' },
            { node = 'item', desc = 'Verbose [D]ebug',  shortcut = 'd', command = 'Piocmdf debug -v' },
          },
        },
      },
    },
    {
      node = 'menu',
      desc = '[R]emote',
      shortcut = 'r',
      items = {
        { node = 'item', desc = 'Remote [U]pload',  shortcut = 'u', command = 'Piocmdf remote run -t upload' },
        { node = 'item', desc = 'Remote [T]est',    shortcut = 't', command = 'Piocmdf remote test' },
        { node = 'item', desc = 'Remote [M]onitor', shortcut = 'm', command = 'Piocmdh remote run -t monitor' },
        { node = 'item', desc = 'Remote [D]evices', shortcut = 'd', command = 'Piocmdf remote device list' },
      },
    },
    {
      node = 'menu',
      desc = '[M]iscellaneous',
      shortcut = 'm',
      items = {
        { node = 'item', desc = '[U]pgrade PlatformIO Core', shortcut = 'u', command = 'Piocmdf upgrade' },
      },
    },
    --   }, --
    -- }, --
  },
}

local valid_menu_keys = {
  node = true,
  desc = true,
  shortcut = true,
  items = true,
}
local valid_item_keys = {
  node = true,
  desc = true,
  shortcut = true,
  command = true,
}
local valid_keys_value = {
  node = 'string',
  desc = 'string',
  shortcut = 'string',
  command = 'string',
  items = 'table',
}

local function dumpTable(tbl)
  local result = ''
  for key, value in pairs(tbl) do
    local isValuString = type(value) == 'string' and "'" or ''
    result = result .. (string.format('%s = %s%s%s,\n', tostring(key), isValuString, tostring(value), isValuString))
  end
  return result
end

local function validateMenu(menu)
  for _, child_node in ipairs(menu) do
    if child_node.node ~= nil then
      if child_node.node == 'menu' then
        for key, value in pairs(child_node) do
          if not valid_menu_keys[key] or type(value) ~= valid_keys_value[key] then
            local error_message = string.format('Invalid PlatformIO menu key-value: %s\n%s', tostring(key),
              dumpTable(child_node))
            vim.api.nvim_echo({ { error_message, 'ErrorMsg' } }, true, {})
            return false
          end
        end
        if not validateMenu(child_node) then
          return false
        end
      elseif child_node.node == 'item' then
        for key, value in pairs(child_node) do
          if not valid_item_keys[key] or type(value) ~= valid_keys_value[key] then
            local error_message = string.format('Invalid PlatformIO item key-value: %s\n%s', tostring(key),
              dumpTable(child_node))
            vim.api.nvim_echo({ { error_message, 'ErrorMsg' } }, true, {})
            return false
          end
        end
      end
    else
      local error_message = string.format('Invalid PlatformIO menu node value: %s', dumpTable(child_node))
      vim.api.nvim_echo({ { error_message, 'ErrorMsg' } }, true, {})
      return false
    end
  end
  return true
end

function M.setup(user_config)
  if next(user_config) ~= nil then
    local valid_keys = {
      lsp = true,
      menu_key = true,
      menu_name = true,
      menu_bindings = true,
    }
    local err = false
    for key, value in pairs(user_config or {}) do
      if not valid_keys[key] then
        local error_message = string.format('Invalid PlatformIO settings key-value: %s = "%s"', key, value)
        vim.api.nvim_echo({ { error_message, 'ErrorMsg' } }, true, {})
        err = true
      end
    end
    if user_config.lsp and not (user_config.lsp == 'ccls' or user_config.lsp == 'clangd') then
      vim.api.nvim_echo(
        { { 'Invalid PlatformIO lsp "' .. user_config.lsp .. '", {allowed "clangd" or "ccls"} (default "' .. M.config.lsp .. '" will be used)', 'ErrorMsg' } },
        true,
        {}
      )
      user_config.lsp = M.config.lsp
    end

    if not err then -- if no error, merge user_config to M.config
      if user_config.menu_bindings then
        if not validateMenu(user_config.menu_bindings) then
          user_config.menu_bindings = nil -- if validation error, cancel merging menu_bindings with M.config
          -- else
          --   print('good validation')
        end
      end
      M.config = vim.tbl_deep_extend('force', M.config, user_config or {})
    end
  end

  require('platformio.piomenu').piomenu(M.config)
end

return M
