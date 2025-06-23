local M = {}

function M.piomenu(config)
  local ok, wk = pcall(require, 'which-key') --will also load the package if it isn't loaded already
  if not ok then
    vim.api.nvim_echo({
      { 'which-key plugin not found!', 'ErrorMsg' },
    }, true, {})
  else
    local prefix = config.menu_key  -- or use 'gp'
    local Piocmd = 'Piocmdf'   -- 'Piocmdh' (horizontal terminal)  'Piocmdf' (float terminal)
    wk.add({
      { prefix, group = ' PlatformIO:' },
      { prefix .. 'g', group = '  [g]eneral' },
      { prefix .. 'd', group = '  [d]ependencies' },
      { prefix .. 'a', group = '  [a]dvance' },
      { prefix .. 'av', group = '  [v]erbose' },
      { prefix .. 'r', group = '  [r]emote' },
      { prefix .. 'm', group = '  [m]iscellaneous' },
      {
        mode = { 'n' }, -- NORMAL mode
        { prefix .. 'l', '<cmd>' .. 'PioTermList' .. ' <CR>', desc = ' Pio Terminals [l]ist' },
        { prefix .. 'gb', '<cmd>' .. Piocmd .. ' run<CR>', desc = ' [b]uild' },
        { prefix .. 'gc', '<cmd>' .. Piocmd .. ' run -t clean<CR>', desc = ' [c]lean' },
        { prefix .. 'gf', '<cmd>' .. Piocmd .. ' run -t fullclean<CR>', desc = ' [f]ull clean' },
        { prefix .. 'gd', '<cmd>' .. Piocmd .. ' device list<CR>', desc = ' [d]evice list' },
        { prefix .. 'gm', '<cmd>' .. 'Piocmdh' .. ' run -t monitor<CR>', desc = ' [m]onitor' },
        { prefix .. 'gu', '<cmd>' .. Piocmd .. ' run -t upload<CR>', desc = ' [u]pload' },
        { prefix .. 'gs', '<cmd>' .. Piocmd .. ' run -t uploadfs<CR>', desc = ' upload file [s]ystem' },
        { prefix .. 'gt', '<cmd>' .. Piocmd .. '<CR>', desc = ' Core CLI [T]erminal' },
    
        { prefix .. 'dl', '<cmd>' .. Piocmd .. ' pkg list<CR>', desc = ' [l]ist packages' },
        { prefix .. 'do', '<cmd>' .. Piocmd .. ' pkg outdated<CR>', desc = ' List [o]utdated packages' },
        { prefix .. 'du', '<cmd>' .. Piocmd .. ' pkg update<CR>', desc = ' [u]pdate packages' },
    
        { prefix .. 'at', '<cmd>' .. Piocmd .. ' test<CR>', desc = ' [t]est' },
        { prefix .. 'ac', '<cmd>' .. Piocmd .. ' check<CR>', desc = ' [c]heck' },
        { prefix .. 'ad', '<cmd>' .. Piocmd .. ' debug<CR>', desc = ' [d]ebug' },
        { prefix .. 'ab', '<cmd>' .. Piocmd .. ' run -t compiledb<CR>', desc = ' compilation data[b]ase' },
    
        { prefix .. 'av', '<cmd>' .. Piocmd .. ' debug<CR>', desc = ' [v]erbose' },
        { prefix .. 'avb', '<cmd>' .. Piocmd .. ' run -v<CR>', desc = ' [b]uild' },
        { prefix .. 'avd', '<cmd>' .. Piocmd .. ' debug -v<CR>', desc = ' [d]ebug' },
        { prefix .. 'avu', '<cmd>' .. Piocmd .. ' run -v -t upload<CR>', desc = ' [u]pload' },
        { prefix .. 'avs', '<cmd>' .. Piocmd .. ' run -v -t uploadfs<CR>', desc = ' upload file [s]ystem' },
        { prefix .. 'avt', '<cmd>' .. Piocmd .. ' test -v<CR>', desc = ' [t]est' },
        { prefix .. 'avc', '<cmd>' .. Piocmd .. ' check -v<CR>', desc = ' [c]heck' },
        { prefix .. 'ava', '<cmd>' .. Piocmd .. ' run -v -t compiledb<CR>', desc = ' compilation databa[a]e' },
    
        { prefix .. 'ru', '<cmd>' .. Piocmd .. ' remote run -t upload<CR>', desc = ' [u]pload' },
        { prefix .. 'rt', '<cmd>' .. Piocmd .. ' remote test<CR>', desc = ' [t]est' },
        { prefix .. 'rm', '<cmd>' .. 'Piocmdh' .. ' remote run -t monitor<CR>', desc = ' [m]onitor' },
        { prefix .. 'rd', '<cmd>' .. Piocmd .. ' remote device list<CR>', desc = ' [d]evice list' },
    
        { prefix .. 'mu', '<cmd>' .. Piocmd .. ' upgrade<CR>', desc = ' [u]pgrade' },
      },
    })
  end
end

return M
