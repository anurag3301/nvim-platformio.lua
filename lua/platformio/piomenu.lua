local M = {}

local icon = { icon = '  ', color = 'orange' } -- Assign platformio orange icon
local wk_table = { mode = { 'n', 'v' } }

local function traverseMenu(menu, wkey)
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

function M.piomenu(config)
  if config.menu_key == nil then
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

  table.insert(wk_table, { config.menu_key, group = config.menu_name, icon = icon })

  traverseMenu(config.menu_bindings, config.menu_key)

  wk.add(wk_table)
end

return M
