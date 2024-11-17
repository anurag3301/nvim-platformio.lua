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
  -- if args == 'upload' then -- checking valid commands
  --   require('platformio.piorun').pioupload()
  -- elseif args == '' then
  --   require('platformio.piorun').pioupload()
  -- elseif args == 'uploadfs' then
  --   require('platformio.piorun').piouploadfs()
  -- elseif args == 'build' then
  --   require('platformio.piorun').piobuild()
  -- elseif args == 'clean' then
  --   require('platformio.piorun').pioclean()
  -- else
  --   vim.api.nvim_err_writeln "Invalid argument. Use 'upload', 'uploadfs', 'build', or 'clean'." -- error message if the cmd is invalid
  -- end
  if args == '' then
    -- No argument provided, run without args
    require('platformio.piorun').piorun {}
  else
    -- One argument provided, pass it as a table
    require('platformio.piorun').piorun { args }
  end
end, {
  nargs = '?', -- Allow zero or one argument
  complete = function(_, _, _)
    return { 'upload', 'uploadfs', 'build', 'clean' } -- Autocompletion options
  end,
})

-- Piomon
vim.api.nvim_create_user_command('Piomon', function(opts)
  local args = opts.args
  if args == '' then
    -- No argument provided, run without args
    require('platformio.piomon').piomon {}
  else
    -- One argument provided, pass it as a table
    require('platformio.piomon').piomon { args }
  end
end, {
  nargs = '?', -- Allow zero or one argument
  complete = function(_, _, _)
    return { '4800', '9600', '57600', '115200' }
  end,
})

-- Piolib
vim.api.nvim_create_user_command('Piolib', function(opts)
  -- Split the args into a table
  local args = vim.split(opts.args, ' ')

  -- Call the piolib function with the arguments
  require('platformio.piolib').piolib(args)
end, {
  nargs = '+', -- means can take another argument
})

-- Piocmd
vim.api.nvim_create_user_command('Piocmd', function(opts)
  -- Split the args into a table
  local cmd_table = vim.split(opts.args, ' ')

  -- Call the piolib function with the arguments
  require('platformio.pioterm').piocmd(cmd_table)
end, {
  nargs = '+', -- means can take another argument
})

-- Piodebug
vim.api.nvim_create_user_command('Piodebug', function()
  require('platformio.piodb').piodb()
end, {})
