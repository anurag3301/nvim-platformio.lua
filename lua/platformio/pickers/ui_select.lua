local M = {}

local function board_label(board)
    return string.format('%s | %s | %s', board.name or '', board.vendor or '', board.platform or '')
end

function M.pick_framework(frameworks, on_select)
    vim.ui.select(frameworks, {
        prompt = 'Select framework:',
        format_item = function(item)
            return item
        end,
    }, function(chosen)
        if chosen then
            on_select(chosen)
        end
    end)
end

function M.pick_board(boards, on_select)
    vim.ui.select(boards, {
        prompt = 'Select board:',
        format_item = board_label,
    }, function(chosen)
        if chosen then
            on_select(chosen)
        end
    end)
end

function M.pick_library(libraries, on_select)
    vim.ui.select(libraries, {
        prompt = 'Select library:',
        format_item = function(item)
            local owner = (item.owner and item.owner.username) or ''
            return string.format('%s | %s | %s', item.name or '', owner, item.description or '')
        end,
    }, function(chosen)
        if chosen then
            on_select(chosen)
        end
    end)
end

function M.pick_terminal(terminals, on_select)
    vim.ui.select(terminals, {
        prompt = 'Select a PIO terminal window:',
        kind = 'PioTerminals',
        format_item = function(item)
            local is_hidden = vim.api.nvim_buf_is_loaded(item.term.bufnr) and (vim.fn.bufwinid(item.term.bufnr) == -1)
            return string.format('%d:%s (hidden: %s)', item.term.id, item.termtype, tostring(is_hidden))
        end,
    }, function(chosen)
        if chosen then
            on_select(chosen)
        else
            on_select(nil)
        end
    end)
end

function M.pick_env(envs, on_select)
    vim.ui.select(envs, {
        prompt = 'Select an environment to use as default:',
    }, function(chosen)
        if chosen then
            on_select(chosen)
        end
    end)
end

return M
