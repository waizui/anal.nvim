local M = {}

local vim = vim

local BlockWin = require("anal.blockwin")

function M.setup(opt)
  if not opt or next(opt) == nil then
    opt = {}
    opt.interval = 1800 -- seconds
  end

  M.start(opt.interval)
end

function M.start(interval)
  local ms = interval * 1000
  local timer = vim.uv.new_timer()
  timer:start(
    ms,
    ms,
    vim.schedule_wrap(function()
      -- close win before next event
      BlockWin.open_blockwin(interval - 1)
    end)
  )
end


return M
