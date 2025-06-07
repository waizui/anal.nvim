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
  BlockWin.lock_win(buf, win)
  BlockWin.start_win_loop(buf, win, cd)
end

---@param b boolean
function BlockWin.validate_keys(buf, b)
  if b then
    -- abbreviations to intercept quit commands
    vim.cmd("cabbrev q lua require('anal').blocked_q()<CR>")
    vim.cmd("cabbrev quit lua require('anal').blocked_q()<CR>")
    vim.cmd("cabbrev wq lua require('anal').blocked_q()<CR>")
    vim.cmd("cabbrev x lua require('anal').blocked_q()<CR>")

    -- Disable key mappings
    vim.api.nvim_buf_set_keymap(
      buf,
      "n",
      "q",
      ":lua require('anal').blocked_q()<CR>",
      { noremap = true, silent = true }
    )
    vim.api.nvim_buf_set_keymap(
      buf,
      "n",
      "<C-c>",
      ":lua require('anal').blocked_q()<CR>",
      { noremap = true, silent = true }
    )
    vim.api.nvim_buf_set_keymap(
      buf,
      "n",
      "ZZ",
      ":lua require('anal').blocked_q()<CR>",
      { noremap = true, silent = true }
    )
    vim.api.nvim_buf_set_keymap(
      buf,
      "n",
      "ZQ",
      ":lua require('anal').blocked_q()<CR>",
      { noremap = true, silent = true }
    )
  else
    -- Clear abbreviations
    pcall(vim.cmd, "cunabbrev q")
    pcall(vim.cmd, "cunabbrev quit")
    pcall(vim.cmd, "cunabbrev wq")
    pcall(vim.cmd, "cunabbrev x")

    -- Clean up keymaps
    pcall(vim.api.nvim_buf_del_keymap, buf, "n", "q")
    pcall(vim.api.nvim_buf_del_keymap, buf, "n", "<C-c>")
    pcall(vim.api.nvim_buf_del_keymap, buf, "n", "ZZ")
    pcall(vim.api.nvim_buf_del_keymap, buf, "n", "ZQ")
  end
end

function BlockWin.lock_win(buf, win)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(buf, "swapfile", false)

  BlockWin.validate_keys(buf, false)

  local augroup = vim.api.nvim_create_augroup("CountdownLock", { clear = true })

  -- Force user back if they try to switch windows
  vim.api.nvim_create_autocmd("WinLeave", {
    group = augroup,
    buffer = buf,
    callback = function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_set_current_win(win)
      end
    end,
  })
end

function BlockWin.blocked_q()
  vim.api.nvim_echo({ { "Window is locked until countdown ends!", "WarningMsg" } }, true, {})
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

      BlockWin.validate_keys(buf, true)

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
