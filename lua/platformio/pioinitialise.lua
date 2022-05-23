local M = {}

function M.pioinit(board)
       vim.cmd("2TermExec cmd='pio project init --board ".. board .. "' direction=float")
end

return M
