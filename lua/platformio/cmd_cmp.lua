local M = {}

function M.complete_piorun(arg_lead, cmd_line, cursor_pos)
	return { "upload", "build", "clean" }
end

return M
