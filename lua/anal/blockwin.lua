local BlockWin = {}

local vim = vim

function BlockWin.open_blockwin(cd)
  local buf = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Stand up! Relax your anal sphincter!" })

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
      string.format("Rest for %d seconds", left_t),
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
