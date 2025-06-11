local M = {}

local vim = vim

local BlockWin = require("anal.blockwin")

function M.setup()
  local config = M.read_options()

  M.reg_command()
  M.start(config.interval, config.display_time)
end

function M.save_options(interval, display_time)
  local config = {
    interval = interval or 1800,
    display_time = display_time or 300,
  }

  local file = io.open(vim.fn.stdpath("data") .. "/anal_config.lua", "w")
  if file then
    file:write("return " .. vim.inspect(config))
    file:close()
  end
end

function M.read_options()
  local ok, saved = pcall(dofile, vim.fn.stdpath("data") .. "/anal_config.lua")
  if ok then
    return saved
  end

  return {
    interval = 1800,
    display_time = 300,
  }
end

function M.start(interval, display_time)
  M.save_options(interval, display_time)
  BlockWin.start(interval, display_time)
end

function M.reg_command()
  -- register command with params
  vim.api.nvim_create_user_command("Anal", function(opts)
    if opts.fargs[1] == "help" then
      vim.api.nvim_echo({
        { "Anal command usage:",             "WarningMsg" },
        { ":Anal [interval] [display_time]", "Comment" },
        {
          "interval: time in seconds to wait before showing the message (default: 1800)",
          "Comment",
        },
        {
          "display_time: time in seconds to display the message (default: 300)",
          "Comment",
        },
      }, false, {})

      return
    end

    local interval = opts.fargs[1] or 1800
    local display_time = opts.fargs[2] or 300
    M.start(interval, display_time)
  end, {
    nargs = "*",
    complete = function(_, _, _)
      return { "1800", "300" } -- default values
    end,
  })
end

return M
