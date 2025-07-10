local M = {}

function M.piomenu(config)


  if config.menu_key == nil or config.menu_bindings == nil then
    return
  end

  local key = vim.api.nvim_replace_termcodes(config.menu_key, true, true, true)
  local mapping = vim.fn.mapcheck(key, "")
  if mapping ~= "" then
    vim.api.nvim_err_writeln(config.menu_key .. " is mapped to: " .. mapping .. ", Leaving piomenu setup!!")
    vim.api.nvim_err_writeln("Pick a different key map for piomenu in setup!!")
    return
  end

  local ok, wk = pcall(require, 'which-key')
  if not ok then
    vim.api.nvim_echo({ { 'which-key plugin not found!', 'ErrorMsg' } }, true, {})
    return
  end

  local prefix = config.menu_key
  local Piocmd = config.piocmd or 'Piocmdf'

  local wk_table = {}

  -- Top level group
  table.insert(wk_table, { prefix, group = ' PlatformIO:' })

  -- Group headers
  for _, group in ipairs(config.menu_bindings) do
    table.insert(wk_table, { prefix .. group.key, group = group.group })
  end

  -- Key mappings
  local commands = { mode = { 'n' } }
  for _, group in ipairs(config.menu_bindings) do
    for _, item in ipairs(group.elements) do
      local full_key = prefix .. group.key .. item.key
      local full_cmd = '<cmd>' .. (item.cmd:find('^Pio') and item.cmd or (Piocmd .. ' ' .. item.cmd)) .. '<CR>'
      table.insert(commands, { full_key, full_cmd, desc = item.desc })
    end
  end

  table.insert(wk_table, commands)

  wk.add(wk_table)
end

return M
