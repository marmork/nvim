local M = {}

--- Moves the current line and corrects the cursor
--- to enable continuous movement.
--- @param direction string "up" oder "down"
function M.move_line(direction)
  local line = vim.fn.line('.') -- Current line number

  if direction == "down" then
    -- Moves the line and goes to the next line (the moved line)
    vim.cmd("move +1")
    vim.api.nvim_win_set_cursor(0, {line + 1, 0})
  else
    -- Moves the line and stays on the same logical line
    vim.cmd("move -2")
    vim.api.nvim_win_set_cursor(0, {line - 1, 0})
  end
end

return M