-- Set the global namespace
_G.om = {}

---Check if a certain feature/version/commit exists in nvim
---@param feature string
---@return boolean
function om.has(feature)
  return vim.fn.has(feature) > 0
end

om.nightly = om.has("nvim-0.10")

local terminals = {}

---Open a floating terminal (interactive by default)
---@param cmd string?
---@param opts table?
---@return function
function om.float_term(cmd, opts)
  opts = vim.tbl_deep_extend("force", {
    ft = "lazyterm",
    size = { width = 0.9, height = 0.9 },
  }, opts or {}, { persistent = true })

  local termkey = vim.inspect({ cmd = cmd or "shell", cwd = opts.cwd, env = opts.env })

  if terminals[termkey] and terminals[termkey]:buf_valid() then
    terminals[termkey]:toggle()
  else
    terminals[termkey] = require("lazy.util").float_term(cmd, opts)
    local buf = terminals[termkey].buf
    vim.b[buf].lazyterm_cmd = cmd
    if opts.esc_esc == false then
      vim.keymap.set("t", "<esc>", "<esc>", { buffer = buf, nowait = true })
    end
    vim.api.nvim_create_autocmd("BufEnter", {
      buffer = buf,
      callback = function()
        vim.cmd.startinsert()
      end,
    })
  end

  return terminals[termkey]
end

---Determine if you're on an external monitor
---@return boolean
function om.on_big_screen()
  return vim.o.columns > 150 and vim.o.lines >= 40
end
