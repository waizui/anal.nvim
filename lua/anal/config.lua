local Config = {}

local vim = vim

local fname = "/anal_config.lua"

---@class Options
local Options = {
  ver = 1,
  interval = 1800,
  display_time = 300,
  naughty = 0,
  text = "Stand up, Time to relax your anus!",
}

---@return Options
function Config.read()
  local ok, saved = pcall(dofile, vim.fn.stdpath("data") .. fname)
  if ok then
    if saved.ver ~= nil and saved.ver >= Options.ver then
      return saved
    else
      return Config.upgrade_opts(saved)
    end
  end

  return Config.default()
end

---@param opts Options
function Config.save(opts)
  local file = io.open(vim.fn.stdpath("data") .. fname, "w")
  if file then
    file:write("return " .. vim.inspect(opts))
    file:close()
  end
end

---@return Options
function Config.default()
  local opts = {}
  for key, value in pairs(Options) do
    opts[key] = value
  end
  return opts
end

---@param old Options
---@return Options
function Config.upgrade_opts(old)
  local default = Config.default()
  for key, value in pairs(old) do
    if default[key] ~= nil then
      default[key] = value
    end
  end

  return default
end

return Config
