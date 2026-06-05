local M = {}

local utils = require('platformio.utils')
local picker = require('platformio.pickers')

local function switch_to_terminal(chosen)
  if not chosen or not chosen.term then
    vim.api.nvim_echo({ { 'No PIO terminal window selected.', 'Normal' } }, true, {})
    return
  end

  local win_type = vim.fn.win_gettype(chosen.term.window)
  local win_open = win_type == '' or win_type == 'popup'
  if chosen.term.window and (win_open and vim.api.nvim_win_get_buf(chosen.term.window) == chosen.term.bufnr) then
    vim.api.nvim_set_current_win(chosen.term.window)
  else
    chosen.term:open()
  end
  vim.api.nvim_echo({ { 'Switched to PIO terminal: ' .. chosen.termtype, 'Normal' } }, true, {})
end

function M.piotermlist()
  local toggleterm_list = {}
  local terms = require('toggleterm.terminal').get_all(true)

  if #terms ~= 0 then
    for i = 1, #terms do
      if terms[i].display_name and terms[i].display_name ~= '' and terms[i].display_name:find('pio', 1) then
        local termtype = utils.strsplit(terms[i].display_name, ':')[1]
        table.insert(toggleterm_list, {
          term = terms[i],
          termtype = termtype,
        })
      end
    end
  end

  if #toggleterm_list == 0 then
    vim.api.nvim_echo({ { 'No PIO terminal windows found.', 'Normal' } }, true, {})
    return
  end

  picker.pick_terminal(toggleterm_list, switch_to_terminal)
end

return M
