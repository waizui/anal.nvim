local M = {}

function M.setup(opt)
  if not opt or next(opt) == nil then
    opt = {}
    opt.interval = 3 --seconds
  end

  M.start(opt.interval)
end

function M.start(interval)
  local timer = vim.uv.new_timer()
  timer:start(
    interval * 1000,
    0,
    vim.schedule_wrap(function()
      print("Stand up! Relax your anal sphincter!")
    end)
  )
  --TODO: impl
end

return M
