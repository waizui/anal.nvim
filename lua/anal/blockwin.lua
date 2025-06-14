local BlockWin = {}

local vim = vim

---@param opts Options
function BlockWin.start(opts)
  local cur_timer = BlockWin.cur_timer
  if cur_timer and cur_timer:is_active() then
    cur_timer:stop()
    cur_timer:close()
    BlockWin.cur_timer = nil
  end

  local interval, display_time = opts.interval, opts.display_time

  local delay_ms = interval * 1000
  local interval_ms = (interval + display_time) * 1000

  local timer = vim.uv.new_timer()
  timer:start(
    delay_ms,  -- delay
    interval_ms, -- interval
    vim.schedule_wrap(function()
      BlockWin.open_blockwin(opts)
    end)
  )
  BlockWin.cur_timer = timer
end

---@param opts Options
function BlockWin.open_blockwin(opts)
  local buf = BlockWin.create_buf()
  -- show reminding text
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { opts.text })

  BlockWin.start_win_loop(buf, opts)
end

---@param opts Options
function BlockWin.start_win_loop(buf, opts)
  local left_t = math.max(1, opts.display_time)
  local timer = vim.uv.new_timer()
  local win = BlockWin.create_win(buf)

  local naughty = (opts.naughty == 1)

  local function update()
    -- Check if buffer and window are still valid
    if not vim.api.nvim_buf_is_valid(buf) then
      timer:stop()
      timer:close()
      return
    end

    local text = string.format("Rest your anus for %d seconds", left_t)

    if naughty then
      if left_t % 2 == 0 then
        pcall(vim.api.nvim_win_close, win, true)
      else
        win = BlockWin.create_win(buf)
        BlockWin.change_text(buf, text)
      end
    else
      BlockWin.change_text(buf, text)
    end

    if left_t <= 0 then
      -- Clean up resources
      timer:stop()
      timer:close()
      -- close window
      pcall(vim.api.nvim_win_close, win, true)
      return
    end

    left_t = left_t - 1
  end

  timer:start(0, 1000, vim.schedule_wrap(update))
end

function BlockWin.create_buf()
  local cur_buf = BlockWin.cur_buf
  if cur_buf and vim.api.nvim_buf_is_valid(cur_buf) then
    pcall(vim.api.nvim_buf_delete, cur_buf, { force = true })
    BlockWin.cur_buf = nil
  end

  local buf = vim.api.nvim_create_buf(false, true)
  BlockWin.cur_buf = buf
  return buf
end

function BlockWin.create_win(buf)
  local cur_win = BlockWin.cur_win
  if cur_win and vim.api.nvim_win_is_valid(cur_win) then
    pcall(vim.api.nvim_win_close, cur_win, true)
    BlockWin.cur_win = nil
  end

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
  BlockWin.cur_win = win
  return win
end

function BlockWin.change_text(buf, text)
  vim.api.nvim_buf_set_option(buf, "modifiable", true)
  vim.api.nvim_buf_set_lines(buf, 1, -1, false, { text })
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
end

function BlockWin.hide_win(buf, win)
  if vim.api.nvim_win_is_valid(win) then
    pcall(vim.api.nvim_win_close, win, true)
  end
end

return BlockWin
