local M = {}

local vim = vim

local BlockWin = require("anal.blockwin")
local Config = require("anal.config")

function M.setup()
  M.reg_command()
  local opts = Config.read()
  M.start(opts)
end

---@param opts Options
function M.start(opts)
  Config.save(opts)
  BlockWin.start(opts)
end

function M.reg_command()
  -- register command with params
  vim.api.nvim_create_user_command("Anal", function(args)
    if args.fargs[1] == "help" then
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
    if args.fargs[1] == "text" then
      local opts = Config.read()
      local txt = table.concat(args.fargs, " ", 2)
      if txt ~= nil and txt ~= "" then
        opts.text = txt
      else
        opts.text = Config.default().text
      end

      M.start(opts)
      return
    end

    if #args.fargs == 2 then
      -- check if args like `:Anal 1800 300`
      local interval, display_time = tonumber(args.fargs[1]), tonumber(args.fargs[2])
      if interval == nil or display_time == nil then
        return
      end

      local opts = Config.read()
      opts.interval = interval
      opts.display_time = display_time

      M.start(opts)
      return
    end
  end, {
    nargs = "*",
    complete = function(_, _, _)
      return { "1800", "300" } -- default values
    end,
  })
end

return M
