local BlockWin = {}

local vim = vim

---@param opts Options
function BlockWin.start(opts)
  if BlockWin.cur_timer and BlockWin.cur_timer:is_active() then
    BlockWin.cur_timer:stop()
    BlockWin.cur_timer:close()
    BlockWin.cur_timer = nil
  end

  local interval, display_time = opts.interval, opts.display_time

  local dalay_ms = interval * 1000
  local interval_ms = (interval + display_time) * 1000
  local timer = vim.uv.new_timer()
  timer:start(
    dalay_ms,  -- delay
    interval_ms, -- interval
    vim.schedule_wrap(function()
      BlockWin.open_blockwin(opts)
    end)
  )
  BlockWin.cur_timer = timer
end

---@param opts Options
function BlockWin.open_blockwin(opts)
  local cd = math.max(1, opts.display_time)
  if BlockWin.cur_win and vim.api.nvim_win_is_valid(BlockWin.cur_win) then
    pcall(vim.api.nvim_win_close, BlockWin.cur_win, true)
    BlockWin.cur_win = nil
  end

  if BlockWin.cur_buf and vim.api.nvim_buf_is_valid(BlockWin.cur_buf) then
    pcall(vim.api.nvim_buf_delete, BlockWin.cur_buf, { force = true })
    BlockWin.cur_buf = nil
  end

  local buf = vim.api.nvim_create_buf(false, true)

  -- show reminding text
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { opts.text })

  local ui = vim.api.nvim_list_uis()[1]
  local editor_width = ui.width
  local editor_height = ui.height

  local win_width = 40
  local win_height = 10

  -- center position
  local row = math.floor((editor_height - win_height) / 2)
  local col = math.floor((editor_width - win_width) / 2)

  local opts = {
    relative = "editor",
    width = win_width,
    height = win_height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
  }

  local win = vim.api.nvim_open_win(buf, true, opts)
  BlockWin.start_win_loop(buf, win, cd)
  BlockWin.cur_buf = buf
  BlockWin.cur_win = win
end

function BlockWin.start_win_loop(buf, win, cd)
  local left_t = cd
  local timer = vim.uv.new_timer()

  local function update()
    -- Check if buffer and window are still valid
    if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_win_is_valid(win) then
      timer:stop()
      timer:close()
      return
    end

    vim.api.nvim_buf_set_option(buf, "modifiable", true)
    vim.api.nvim_buf_set_lines(buf, 1, -1, false, {
      "",
      string.format("Rest your anus for %d seconds", left_t),
      "",
    })
    vim.api.nvim_buf_set_option(buf, "modifiable", false)

    if left_t <= 0 then
      -- Clean up resources
      timer:stop()
      timer:close()

      -- Clean up autocommand group
      pcall(vim.api.nvim_del_augroup_by_name, "CountdownLock")
      -- Close the window safely
      pcall(vim.api.nvim_win_close, win, true)
      return
    end

    left_t = left_t - 1
  end

  timer:start(0, 1000, vim.schedule_wrap(update))
end

return BlockWin
