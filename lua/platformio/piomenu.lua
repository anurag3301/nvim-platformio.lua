local M = {}

function M.piomenu(config)
  if config.menu_key == nil then
    return
  end

  local key = vim.api.nvim_replace_termcodes(config.menu_key, true, true, true)
  local mapping = vim.fn.mapcheck(key, '')
  if mapping ~= '' then
    vim.api.nvim_echo({
      { config.menu_key .. ' is mapped to: ' .. mapping .. ', Leaving piomenu setup!!', 'ErrorMsg' },
    }, true, {})
    vim.api.nvim_echo({
      { 'Pick a different key map for piomenu in setup!!', 'ErrorMsg' },
    }, true, {})
    return
  end

  local ok, wk = pcall(require, 'which-key')
  if not ok then
    vim.api.nvim_echo({ { 'which-key plugin not found!', 'ErrorMsg' } }, true, {})
    return
  end

  wk.setup({
    preset = 'helix', --'modern', --"classic", --
  })
  local Config = require('which-key.config')
  Config.sort = { 'order', 'group', 'manual', 'mod' }

  local icon = { icon = '  ', color = 'orange' } -- Assign platformio orange icon

  local wk_table = { mode = { 'n', 'v' } }
  table.insert(wk_table, { config.menu_key, group = config.menu_name, icon = icon })

  local function traverseMenu(menu, wkey)
    wkey = wkey or config.menu_key
    for _, child_node in ipairs(menu) do
      if child_node.node == 'menu' then
        traverseMenu(child_node.items, wkey .. child_node.shortcut)
        table.insert(wk_table, { wkey .. child_node.shortcut, group = child_node.desc, icon = icon })
      elseif child_node.node == 'item' then
        table.insert(wk_table, {
          wkey .. child_node.shortcut,
          '<cmd> ' .. child_node.command .. '<CR>',
          desc = child_node.desc,
          icon = icon,
        })
      end
    end
  end
  traverseMenu(config.menu_bindings)

  wk.add(wk_table)
end

return M
