-- Vim nargs options
-- 0: No arguments.
-- 1: Exactly one argument.
-- ?: Zero or one argument.
-- *: Any number of arguments (including none).
-- +: At least one argument.
-- -1: Zero or one argument (like ?, explicitly).

-- Pioinit
vim.api.nvim_create_user_command('Pioinit', function()
  require('platformio.pioinit').pioinit()
end, {})

-- Piodb
vim.api.nvim_create_user_command('Piodb', function()
  require('platformio.piodb').piodb()
end, {})

-- Piorun
vim.api.nvim_create_user_command('Piorun', function(opts)
  local args = opts.args
  require('platformio.piorun').piorun { args }
end, {
  nargs = '?',
  complete = function(_, _, _)
    return { 'upload', 'uploadfs', 'build', 'clean' } -- Autocompletion options
  end,
})

-- Piomon
vim.api.nvim_create_user_command('Piomon', function(opts)
  local args = opts.args
  require('platformio.piomon').piomon { args }
end, {
  nargs = '?',
  complete = function(_, _, _)
    return { '4800', '9600', '57600', '115200' }
  end,
})

-- Piolib
vim.api.nvim_create_user_command('Piolib', function(opts)
  local args = vim.split(opts.args, ' ')
  require('platformio.piolib').piolib(args)
end, {
  nargs = '+',
})

-- Piocmdh    Piocmd horizontal terminal
vim.api.nvim_create_user_command('Piocmdh', function(opts)
  local cmd_table = vim.split(opts.args, ' ')
  require('platformio.piocmd').piocmd(cmd_table, 'horizontal')
end, {
  nargs = '*',
})

-- Piocmdf    Piocmd float terminal
vim.api.nvim_create_user_command('Piocmdf', function(opts)
  local cmd_table = vim.split(opts.args, ' ')
  require('platformio.piocmd').piocmd(cmd_table, 'float')
end, {
  nargs = '*',
})

-- Piodebug
vim.api.nvim_create_user_command('Piodebug', function()
  require('platformio.piodebug').piodebug()
end, {})

-- Piomenu
vim.api.nvim_create_user_command('Piomenu', function()
  require('platformio.piomenu').piomenu()
end, {})
------------------------------------------------------

-- INFO: List ToggleTerminals
vim.api.nvim_create_user_command('PioTermList', function()
  local utils = require 'platformio.utils'
  local toggleterm_list = {}

  local terms = require('toggleterm.terminal').get_all(true)
  if #terms ~= 0 then
    for i = 1, #terms do
      if terms[i].display_name:find('pio', 1) then
        local termtype = utils.strsplit(terms[i].display_name, ':')[1]
        table.insert(toggleterm_list, {
          text = string.format('%d: %s (hidden: %s)', terms[i].id, termtype or '', tostring(terms[i].hidden)),
          term = terms[i],
          id = terms[i].id,
          termtype = termtype, -- Store the terminal type [piomon or piocli]
        })
      end
    end
  end

  if #toggleterm_list == 0 then
    vim.api.nvim_echo({ { 'No PIO Toggleterm windows found.', 'Normal' } }, true, {})
    return
  end

  local display_items = {}
  for _, item in ipairs(toggleterm_list) do
    table.insert(display_items, item.text) -- Use the constructed 'text'
  end

  vim.ui.select(display_items, {
    prompt = 'Select a Toggleterm window:',
    kind = 'ToggletermWindow',
  }, function(selected_item, idx)
    if selected_item then
      local chosen = toggleterm_list[idx]
      local win_type = vim.fn.win_gettype(chosen.term.window)
      local win_open = win_type == '' or win_type == 'popup'
      if chosen.term.window and (win_open and vim.api.nvim_win_get_buf(chosen.term.window) == chosen.term.bufnr) then
        vim.api.nvim_set_current_win(chosen.term.window)
      else
        chosen.term:open()
      end
      vim.api.nvim_echo({ { 'Switched to Toggleterm: ' .. chosen.termtype, 'Normal' } }, true, {})
    else
      vim.api.nvim_echo({ { 'No PIO Toggleterm window selected.', 'Normal' } }, true, {})
    end
  end)
end, {})
