local MiniPick = require('mini.pick')

local M = {}

local SEP = ' | '
local COLUMN_NS = vim.api.nvim_create_namespace('platformio_pick_columns')

local function to_items(list, label_fn)
  local items = {}
  for i, entry in ipairs(list) do
    items[i] = { text = label_fn(entry), data = entry }
  end
  return items
end

local function pad(text, width)
  text = text or ''
  if #text >= width then
    return text:sub(1, width)
  end
  return text .. string.rep(' ', width - #text)
end

local function framework_label(framework)
  return framework
end

local BOARD_NAME_W, BOARD_VENDOR_W = 35, 20

local function board_label(board)
  return pad(board.name or '', BOARD_NAME_W) .. SEP .. pad(board.vendor or '', BOARD_VENDOR_W) .. SEP .. (board.platform or '')
end

local LIB_NAME_W, LIB_OWNER_W = 20, 20

local function library_label(lib)
  local owner = (lib.owner and lib.owner.username) or ''
  return pad(lib.name or '', LIB_NAME_W) .. SEP .. pad(owner, LIB_OWNER_W) .. SEP .. (lib.description or '')
end

local function terminal_label(entry)
  local is_hidden = vim.api.nvim_buf_is_loaded(entry.term.bufnr) and (vim.fn.bufwinid(entry.term.bufnr) == -1)
  return string.format('%d:%s (hidden: %s)', entry.term.id, entry.termtype, tostring(is_hidden))
end

local function data_preview(buf_id, item)
  vim.bo[buf_id].filetype = 'lua'
  vim.bo[buf_id].modifiable = true
  vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, vim.split(vim.inspect(item.data), '\n'))
  vim.bo[buf_id].modifiable = false
end

-- Colors the two padded columns and the separators on top of mini.pick's default
-- rendering (which still handles line text + query match highlighting).
local function columns_show(col1_w, col2_w, hl1, hl2)
  return function(buf_id, items, query)
    MiniPick.default_show(buf_id, items, query)
    vim.api.nvim_buf_clear_namespace(buf_id, COLUMN_NS, 0, -1)
    local sep_len = #SEP
    local col2_start = col1_w + sep_len
    local col2_end = col2_start + col2_w
    local opts = { hl_mode = 'combine', priority = 100 }
    for i = 1, #items do
      local row = i - 1
      pcall(vim.api.nvim_buf_set_extmark, buf_id, COLUMN_NS, row, 0, vim.tbl_extend('force', opts, { end_col = col1_w, hl_group = hl1 }))
      pcall(vim.api.nvim_buf_set_extmark, buf_id, COLUMN_NS, row, col1_w, vim.tbl_extend('force', opts, { end_col = col2_start, hl_group = 'Delimiter' }))
      pcall(vim.api.nvim_buf_set_extmark, buf_id, COLUMN_NS, row, col2_start, vim.tbl_extend('force', opts, { end_col = col2_end, hl_group = hl2 }))
      pcall(
        vim.api.nvim_buf_set_extmark,
        buf_id,
        COLUMN_NS,
        row,
        col2_end,
        vim.tbl_extend('force', opts, { end_col = col2_end + sep_len, hl_group = 'Delimiter' })
      )
    end
  end
end

local board_show = columns_show(BOARD_NAME_W, BOARD_VENDOR_W, 'Title', 'Comment')
local library_show = columns_show(LIB_NAME_W, LIB_OWNER_W, 'Title', 'Comment')

local function open_picker(items, name, on_select, preview_fn, show_fn)
  MiniPick.start({
    source = {
      items = items,
      name = name,
      preview = preview_fn,
      show = show_fn,
      choose = function(item)
        if item then
          on_select(item.data)
        end
        return false
      end,
    },
  })
end

function M.pick_framework(frameworks, on_select)
  open_picker(to_items(frameworks, framework_label), 'Frameworks', on_select)
end

function M.pick_board(boards, on_select)
  open_picker(to_items(boards, board_label), 'Boards', on_select, data_preview, board_show)
end

function M.pick_library(libraries, on_select)
  open_picker(to_items(libraries, library_label), 'Libraries', on_select, data_preview, library_show)
end

function M.pick_terminal(terminals, on_select)
  open_picker(to_items(terminals, terminal_label), 'PIO terminals', on_select)
end

return M
