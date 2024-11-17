-- Pioinit
vim.api.nvim_create_user_command("Pioinit", function()
	require("platformio.pioinit").pioinit()
end, {})

-- Piodb
vim.api.nvim_create_user_command("Piodb", function()
	require("platformio.piodb").piodb()
end, {})

-- Piorun
vim.api.nvim_create_user_command("Piorun", function(opts)
	local args = opts.args
	if args == "upload" then -- checking valid commands
		require("platformio.piorun").pioupload()
	elseif args == "build" then
		require("platformio.piorun").piobuild()
	elseif args == "clean" then
		require("platformio.piorun").pioclean()
	elseif args == "uploadfs" then
		require("platformio.piorun").piouploadfs()
	else
		vim.api.nvim_err_writeln("Invalid argument. Use 'upload', 'uploadfs', 'build', or 'clean'.") -- error message if the cmd is invalid
	end
end, {
	nargs = 1, -- Only one argument is expected
	complete = function(_, _, _)
		return { "upload", "build", "clean" } -- Autocompletion options
	end,
})

-- Piomon
-- https://docs.arduino.cc/learn/communication/uart/ as a base
vim.api.nvim_create_user_command("Piomon", function(opts)
	local args = opts.args -- the piomon function will take care of argument error
	if args ~= 0 then
		require("platformio.piomon").piomon(args)
	else
		vim.api.nvim_err_writeln("Invalid argument or missing argument. Use 'baud rate', example: `:Piomon 115200`")
	end
end, {
	nargs = 1,
	complete = function(_, _, _)
		return { 4800, 9600, 57600, 115200 }
	end,
})

-- Piolib
vim.api.nvim_create_user_command("Piolib", function(opts)
	-- Split the args into a table
	local args = vim.split(opts.args, " ")

	-- Call the piolib function with the arguments
	require("platformio.piolib").piolib(args)
end, {
	nargs = "+", -- means can take another argument
})

-- Piocmd
vim.api.nvim_create_user_command("Piocmd", function(opts)
	-- Split the args into a table
	local cmd_table = vim.split(opts.args, " ")

	-- Call the piolib function with the arguments
	require("platformio.pioterm").piocmd(cmd_table)
end, {
	nargs = "+", -- means can take another argument
})

-- Piodebug
vim.api.nvim_create_user_command("Piodebug", function()
	require("platformio.piodb").piodb()
end, {})
