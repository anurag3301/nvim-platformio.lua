local Snacks = require('snacks')
local align = Snacks.picker.util.align

local M = {}

local SEP = ' ▏'

local function to_items(list, text_fn)
  local items = {}
  for i, entry in ipairs(list) do
    items[i] = { idx = i, text = text_fn(entry), data = entry }
  end
  return items
end

local function plain_format(item)
  return { { item.text } }
end

local function framework_text(framework)
  return framework
end

local function board_text(board)
  return string.format('%s %s %s', board.name or '', board.vendor or '', board.platform or '')
end

local function board_format(item)
  local board = item.data
  return {
    { align(board.name or '', 35, { truncate = true }), 'SnacksPickerLabel' },
    { SEP, 'SnacksPickerDelim' },
    { align(board.vendor or '', 20, { truncate = true }), 'SnacksPickerComment' },
    { SEP, 'SnacksPickerDelim' },
    { board.platform or '' },
  }
end

local function library_text(lib)
  local owner = (lib.owner and lib.owner.username) or ''
  return string.format('%s %s %s', lib.name or '', owner, lib.description or '')
end

local function library_format(item)
  local lib = item.data
  local owner = (lib.owner and lib.owner.username) or ''
  return {
    { align(lib.name or '', 20, { truncate = true }), 'SnacksPickerLabel' },
    { SEP, 'SnacksPickerDelim' },
    { align(owner, 20, { truncate = true }), 'SnacksPickerComment' },
    { SEP, 'SnacksPickerDelim' },
    { lib.description or '' },
  }
end

local function terminal_text(entry)
  local is_hidden = vim.api.nvim_buf_is_loaded(entry.term.bufnr) and (vim.fn.bufwinid(entry.term.bufnr) == -1)
  return string.format('%d:%s (hidden: %s)', entry.term.id, entry.termtype, tostring(is_hidden))
end

local function terminal_format(item)
  local entry = item.data
  local is_hidden = vim.api.nvim_buf_is_loaded(entry.term.bufnr) and (vim.fn.bufwinid(entry.term.bufnr) == -1)
  return {
    { align(tostring(entry.term.id), 3, { align = 'right' }), 'SnacksPickerLabel' },
    { SEP, 'SnacksPickerDelim' },
    { align(entry.termtype, 8), 'SnacksPickerComment' },
    { SEP, 'SnacksPickerDelim' },
    { 'hidden: ' .. tostring(is_hidden) },
  }
end

local function data_preview(ctx)
  vim.bo[ctx.buf].filetype = 'lua'
  vim.bo[ctx.buf].modifiable = true
  vim.api.nvim_buf_set_lines(ctx.buf, 0, -1, false, vim.split(vim.inspect(ctx.item.data), '\n'))
  vim.bo[ctx.buf].modifiable = false
  return true
end

local function open_picker(items, title, on_select, format_fn, preview_fn, layout)
  Snacks.picker.pick({
    title = title,
    items = items,
    format = format_fn or plain_format,
    preview = preview_fn,
    layout = layout,
    confirm = function(picker, item)
      picker:close()
      if item then
        on_select(item.data)
      end
    end,
  })
end

function M.pick_framework(frameworks, on_select)
  -- a bare framework name has nothing worth previewing, so skip the preview pane entirely
  open_picker(to_items(frameworks, framework_text), 'Frameworks', on_select, nil, nil, { preview = false })
end

function M.pick_board(boards, on_select)
  open_picker(to_items(boards, board_text), 'Boards', on_select, board_format, data_preview)
end

function M.pick_library(libraries, on_select)
  open_picker(to_items(libraries, library_text), 'Libraries', on_select, library_format, data_preview)
end

function M.pick_terminal(terminals, on_select)
  open_picker(to_items(terminals, terminal_text), 'PIO terminals', on_select, terminal_format, data_preview)
end

return M
