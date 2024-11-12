vim.api.nvim_create_user_command("Piorun", function(opts)
	local args = vim.split(opts.args, " ")
	if vim.tbl_contains({ "upload", "build", "clean" }, args[1]) then
		require("platformio.piorun").piorun(args)
	else
		vim.api.nvim_err_writeln("Invalid argument. Use 'upload', 'build', or 'clean'.")
	end
end, {
	nargs = 1, -- Only one argument is expected
	complete = function(_, _, _)
		return { "upload", "build", "clean" } -- Autocompletion options
	end,
})
