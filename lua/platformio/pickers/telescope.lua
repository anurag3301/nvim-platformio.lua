local M = {}

local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local telescope_conf = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local entry_display = require('telescope.pickers.entry_display')
local make_entry = require('telescope.make_entry')
local previewers = require('telescope.previewers')
local utils = require('platformio.utils')

local function boardentry_maker(opts)
    local displayer = entry_display.create({
        separator = '▏',
        items = {
            { width = 35 },
            { width = 20 },
            { width = 15 },
        },
    })

    local make_display = function(entry)
        return displayer({
            entry.value.name,
            entry.value.vendor,
            entry.value.platform,
        })
    end

    return function(entry)
        return make_entry.set_default_entry_mt({
            value = {
                id = entry.id,
                name = entry.name,
                vendor = entry.vendor,
                platform = entry.platform,
                data = entry,
            },
            ordinal = entry.name .. ' ' .. entry.vendor .. ' ' .. entry.platform,
            display = make_display,
        }, opts)
    end
end

local function libentry_maker(opts)
    local displayer = entry_display.create({
        separator = '▏',
        items = {
            { width = 20 },
            { width = 20 },
            { remaining = true },
        },
    })

    local make_display = function(entry)
        return displayer({
            entry.value.name,
            entry.value.owner,
            entry.value.description,
        })
    end

    return function(entry)
        return make_entry.set_default_entry_mt({
            value = {
                name = entry.name,
                owner = entry.owner and entry.owner.username or '',
                description = entry.description,
                data = entry,
            },
            ordinal = (entry.name or '') .. ' ' .. (entry.owner and entry.owner.username or '') .. ' ' .. (entry.description or ''),
            display = make_display,
        }, opts)
    end
end

function M.pick_framework(frameworks, on_select)
    local opts = {}
    pickers
        .new(opts, {
            prompt_title = 'frameworks',
            finder = finders.new_table({
                results = frameworks,
            }),
            attach_mappings = function(prompt_bufnr, _)
                actions.select_default:replace(function()
                    actions.close(prompt_bufnr)
                    local selection = action_state.get_selected_entry()
                    if selection then
                        on_select(selection[1] or selection.value)
                    end
                end)
                return true
            end,
            sorter = telescope_conf.generic_sorter(opts),
        })
        :find()
end

function M.pick_board(boards, on_select)
    local opts = {}
    pickers
        .new(opts, {
            prompt_title = 'Boards',
            finder = finders.new_table({
                results = boards,
                entry_maker = opts.entry_maker or boardentry_maker(opts),
            }),
            attach_mappings = function(prompt_bufnr, _)
                actions.select_default:replace(function()
                    actions.close(prompt_bufnr)
                    local selection = action_state.get_selected_entry()
                    if selection and selection.value then
                        on_select(selection.value.data)
                    end
                end)
                return true
            end,
            previewer = previewers.new_buffer_previewer({
                title = 'Board Info',
                define_preview = function(self, entry, _)
                    local json = utils.strsplit(vim.inspect(entry.value.data), '\n')
                    local bufnr = self.state.bufnr
                    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, json)
                    vim.api.nvim_set_option_value('filetype', 'lua', { buf = bufnr })
                    vim.defer_fn(function()
                        local win = self.state.winid
                        vim.api.nvim_set_option_value('wrap', true, { scope = 'local', win = win })
                        vim.api.nvim_set_option_value('linebreak', true, { scope = 'local', win = win })
                        vim.api.nvim_set_option_value('wrapmargin', 2, { buf = bufnr })
                    end, 0)
                end,
            }),
            sorter = telescope_conf.generic_sorter(opts),
        })
        :find()
end

function M.pick_library(libraries, on_select)
    local opts = {}
    pickers
        .new(opts, {
            prompt_title = 'Libraries',
            finder = finders.new_table({
                results = libraries,
                entry_maker = opts.entry_maker or libentry_maker(opts),
            }),
            attach_mappings = function(prompt_bufnr, _)
                actions.select_default:replace(function()
                    actions.close(prompt_bufnr)
                    local selection = action_state.get_selected_entry()
                    if selection and selection.value then
                        on_select(selection.value.data)
                    end
                end)
                return true
            end,
            previewer = previewers.new_buffer_previewer({
                title = 'Package Info',
                define_preview = function(self, entry, _)
                    local json = utils.strsplit(vim.inspect(entry.value.data), '\n')
                    local bufnr = self.state.bufnr
                    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, json)
                    vim.api.nvim_set_option_value('filetype', 'lua', { buf = bufnr })
                    vim.defer_fn(function()
                        local win = self.state.winid
                        vim.api.nvim_set_option_value('wrap', true, { scope = 'local', win = win })
                        vim.api.nvim_set_option_value('linebreak', true, { scope = 'local', win = win })
                        vim.api.nvim_set_option_value('wrapmargin', 2, { buf = bufnr })
                    end, 0)
                end,
            }),
            sorter = telescope_conf.generic_sorter(opts),
        })
        :find()
end

function M.pick_terminal(terminals, on_select)
    local opts = {}
    pickers
        .new(opts, {
            prompt_title = 'PIO terminals',
            finder = finders.new_table({
                results = terminals,
                entry_maker = function(entry)
                    local is_hidden = vim.api.nvim_buf_is_loaded(entry.term.bufnr) and (vim.fn.bufwinid(entry.term.bufnr) == -1)
                    local label = string.format('%d:%s (hidden: %s)', entry.term.id, entry.termtype, tostring(is_hidden))
                    return {
                        value = entry,
                        display = label,
                        ordinal = label,
                    }
                end,
            }),
            attach_mappings = function(prompt_bufnr, _)
                actions.select_default:replace(function()
                    actions.close(prompt_bufnr)
                    local selection = action_state.get_selected_entry()
                    if selection and selection.value then
                        on_select(selection.value)
                    end
                end)
                return true
            end,
            sorter = telescope_conf.generic_sorter(opts),
        })
        :find()
end

function M.pick_env(envs, on_select)
    local opts = {}
    pickers
        .new(opts, {
            prompt_title = 'Environments',
            finder = finders.new_table({
                results = envs,
            }),
            attach_mappings = function(prompt_bufnr, _)
                actions.select_default:replace(function()
                    actions.close(prompt_bufnr)
                    local selection = action_state.get_selected_entry()
                    if selection and selection.value then
                        on_select(selection.value)
                    end
                end)
                return true
            end,
            sorter = telescope_conf.generic_sorter(opts),
        })
        :find()
end

return M
