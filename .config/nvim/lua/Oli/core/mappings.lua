local M = {}
local silent = { noremap = true, silent = true }
local noisy = { noremap = true, silent = false }
------------------------------------NOTES----------------------------------- {{{
--[[
        Some notes on how I structure my key mappings within Neovim

        * All key mappings from across my configuration live in this file
        * The general structue of my mappings are:
        	1) Ctrl - Used for your most frequent and easy to remember mappings
        	2) Local Leader - Used for commands related to filetype/buffer options
        	3) Leader - Used for commands that are global or span Neovim

        * The which-key.nvim plugin is used as a popup to remind me of possible
        key bindings. Pressing either the Leader or Local Leader key will result
        in which-key appearing
]]
---------------------------------------------------------------------------- }}}
-----------------------------------LEADERS---------------------------------- {{{
vim.g.mapleader = " " -- space is the leader!
vim.g.maplocalleader = ","
---------------------------------------------------------------------------- }}}
-----------------------------------DEFAULTS--------------------------------- {{{
M.default_keymaps = function()
  local maps = {
    { "jk", "<esc>", description = "Escape in insert mode", mode = { "i" } },

    { "<Leader>qa", "<cmd>qall<CR>", description = "Quit Neovim" },
    { "<C-s>", "<cmd>silent! write<CR>", description = "Save buffer", mode = { "n", "i" } },
    { "<C-n>", "<cmd>enew<CR>", description = "New buffer" },
    { "<C-y>", "<cmd>%y+<CR>", description = "Copy buffer" },

    { "<LocalLeader>,", "<cmd>norm A,<CR>", description = "Append comma" },
    { "<LocalLeader>;", "<cmd>norm A;<CR>", description = "Append semicolon" },

    { "<LocalLeader>(", [[ciw(<c-r>")<esc>]], description = "Wrap in brackets ()" },
    { "<LocalLeader>(", [[c(<c-r>")<esc>]], description = "Wrap in brackets ()", mode = { "v" } },
    { "<LocalLeader>{", [[ciw{<c-r>"}<esc>]], description = "Wrap in curly braces {}" },
    { "<LocalLeader>{", [[c{<c-r>"}<esc>]], description = "Wrap in curly braces {}", mode = { "v" } },
    { '<LocalLeader>"', [[ciw"<c-r>""<esc>]], description = "Wrap in quotes" },
    { '<LocalLeader>"', [[c"<c-r>""<esc>]], description = "Wrap in quotes", mode = { "v" } },

    {
      "<LocalLeader>[",
      [[:%s/\<<C-r>=expand("<cword>")<CR>\>/]],
      description = "Replace cursor words in file",
      opts = { silent = false },
    },
    { "<LocalLeader>]", [[:s/\<<C-r>=expand("<cword>")<CR>\>/]], description = "Replace cursor words in line" },

    { "<LocalLeader>U", "gUiw`", description = "Capitalize word" },

    { "<", "<gv", description = "Outdent", mode = { "v" } },
    { ">", ">gv", description = "Indent", mode = { "v" } },

    { "<Esc>", "<cmd>:noh<CR>", description = "Clear searches" },
    {
      "<LocalLeader>f",
      ":s/{search}/{replace}/g",
      description = "Search and replace",
      mode = { "n", "v" },
      opts = { silent = false },
    },
    { "B", "^", description = "Beginning of a line" },
    { "E", "$", description = "End of a line" },
    { "<CR>", "o<Esc>", "Insert blank line below" },
    { "<S-CR>", "O<Esc>", "Insert blank line above" },

    { "<LocalLeader>sc", "<C-w>q", description = "Split: Close" },
    { "<LocalLeader>so", "<C-w>o", description = "Split: Close all but current" },

    { "∆", "<cmd>move+<CR>==", description = "Move line down" },
    { "˚", "<cmd>move-2<CR>==", description = "Move line up" },
    { "∆", ":move'>+<CR>='[gv", description = "Move line down", mode = { "v" } },
    { "˚", ":move-2<CR>='[gv", description = "Move line up", mode = { "v" } },
  }

  -- Allow using of the alt key
  -- vim.api.nvim_set_keymap("n", "¬", "<a-l>", silent)
  -- vim.api.nvim_set_keymap("n", "˙", "<a-h>", silent)
  -- vim.api.nvim_set_keymap("n", "∆", "<a-j>", silent)
  -- vim.api.nvim_set_keymap("n", "˚", "<a-k>", silent)

  -- Tabs
  -- vim.api.nvim_set_keymap("n", "<Leader>te", "<cmd>tabe %<CR>", silent)
  -- vim.api.nvim_set_keymap("n", "<Leader>to", "<cmd>tabonly<CR>", silent)
  -- vim.api.nvim_set_keymap("n", "<Leader>tc", "<cmd>tabclose<CR>", silent)

  -- Next tab is gt
  -- Previous tab is gT

  -- Terminal mode
  vim.api.nvim_set_keymap("t", "jk", "<C-\\><C-n>", silent) -- Easy escape in terminal mode
  vim.api.nvim_set_keymap("t", "<esc>", "<C-\\><C-n>", {}) -- Escape in the terminal closes it
  vim.api.nvim_set_keymap("t", ":q!", "<C-\\><C-n>:q!<CR>", {}) -- In the terminal :q quits it

  -- Movement
  -- Automatically save movements larger than 5 lines to the jumplist
  -- Use Ctrl-o/Ctrl-i to navigate backwards and forwards through the jumplist
  vim.api.nvim_set_keymap(
    "n",
    "j",
    "v:count ? (v:count > 5 ? \"m'\" . v:count : '') . 'j' : 'gj'",
    { noremap = true, expr = true }
  )
  vim.api.nvim_set_keymap(
    "n",
    "k",
    "v:count ? (v:count > 5 ? \"m'\" . v:count : '') . 'k' : 'gk'",
    { noremap = true, expr = true }
  )

  -- Multiple cursors
  -- http://www.kevinli.co/posts/2017-01-19-multiple-cursors-in-500-bytes-of-vimscript/
  -- https://github.com/akinsho/dotfiles/blob/45c4c17084d0aa572e52cc177ac5b9d6db1585ae/.config/nvim/plugin/mappings.lua#L298

  -- 1. Position the cursor anywhere in the word you wish to change;
  -- 2. Hit cn, type the new word, then go back to Normal mode;
  -- 3. Hit . n-1 times, where n is the number of replacements.
  vim.api.nvim_set_keymap("n", "cn", "*``cgn", silent) -- Changing a word
  vim.api.nvim_set_keymap("n", "cN", "*``cgN", silent) -- Changing a word (in backwards direction)

  -- 1. Position the cursor over a word; alternatively, make a selection.
  -- 2. Hit cq to start recording the macro.
  -- 3. Once you are done with the macro, go back to normal mode.
  -- 4. Hit Enter to repeat the macro over search matches.
  function om.mappings.setup_mc()
    vim.keymap.set(
      "n",
      "<Enter>",
      [[:nnoremap <lt>Enter> n@z<CR>q:<C-u>let @z=strpart(@z,0,strlen(@z)-1)<CR>n@z]],
      { remap = true, silent = true }
    )
  end
  vim.g.mc = vim.api.nvim_replace_termcodes([[y/\V<C-r>=escape(@", '/')<CR><CR>]], true, true, true)
  vim.api.nvim_set_keymap("x", "cn", [[g:mc . "``cgn"]], { expr = true, silent = true })
  vim.api.nvim_set_keymap("x", "cN", [[g:mc . "``cgN"]], { expr = true, silent = true })
  vim.api.nvim_set_keymap("n", "cq", [[:\<C-u>call v:lua.om.mappings.setup_mc()<CR>*``qz]], { silent = true })
  vim.api.nvim_set_keymap("n", "cQ", [[:\<C-u>call v:lua.om.mappings.setup_mc()<CR>#``qz]], { silent = true })
  vim.api.nvim_set_keymap(
    "x",
    "cq",
    [[":\<C-u>call v:lua.om.mappings.setup_mc()<CR>gv" . g:mc . "``qz"]],
    { expr = true }
  )

  return maps
end
---------------------------------------------------------------------------- }}}
-----------------------------------PLUGINS---------------------------------- {{{
M.plugin_keymaps = function()
  local h = require("legendary.helpers")
  return {
    -- Legendary
    { "<C-p>", require("legendary").find, description = "Search keybinds and commands", mode = { "n", "i", "v" } },

    -- Aerial
    { "<C-t>", "<cmd>AerialToggle<CR>", description = "Aerial", opts = silent },

    -- Buffer delete
    { "<C-c>", "<cmd>Bwipeout!<CR>", description = "Close Buffer", opts = silent },

    -- Bufferline
    { "<Tab>", "<Plug>(cokeline-focus-next)", description = "Next buffer", opts = { noremap = false } },
    { "<S-Tab>", "<Plug>(cokeline-focus-prev)", description = "Previous buffer", opts = { noremap = false } },
    { "<LocalLeader>1", "<Plug>(cokeline-focus-1)", description = "Buffer focus on 1", opts = silent },
    { "<LocalLeader>2", "<Plug>(cokeline-focus-2)", description = "Buffer focus on 2", opts = silent },
    { "<LocalLeader>3", "<Plug>(cokeline-focus-3)", description = "Buffer focus on 3", opts = silent },
    { "<LocalLeader>4", "<Plug>(cokeline-focus-4)", description = "Buffer focus on 4", opts = silent },
    { "<LocalLeader>5", "<Plug>(cokeline-focus-5)", description = "Buffer focus on 5", opts = silent },
    { "<LocalLeader>6", "<Plug>(cokeline-focus-6)", description = "Buffer focus on 6", opts = silent },
    { "<LocalLeader>7", "<Plug>(cokeline-focus-7)", description = "Buffer focus on 7", opts = silent },
    { "<LocalLeader>8", "<Plug>(cokeline-focus-8)", description = "Buffer focus on 8", opts = silent },
    { "<LocalLeader>9", "<Plug>(cokeline-focus-9)", description = "Buffer focus on 9", opts = silent },
    { "<Leader>1", "<Plug>(cokeline-switch-1)", description = "Buffer switch to 1", opts = silent },
    { "<Leader>2", "<Plug>(cokeline-switch-2)", description = "Buffer switch to 2", opts = silent },
    { "<Leader>3", "<Plug>(cokeline-switch-3)", description = "Buffer switch to 3", opts = silent },
    { "<Leader>4", "<Plug>(cokeline-switch-4)", description = "Buffer switch to 4", opts = silent },
    { "<Leader>5", "<Plug>(cokeline-switch-5)", description = "Buffer switch to 5", opts = silent },
    { "<Leader>6", "<Plug>(cokeline-switch-6)", description = "Buffer switch to 6", opts = silent },
    { "<Leader>7", "<Plug>(cokeline-switch-7)", description = "Buffer switch to 7", opts = silent },
    { "<Leader>8", "<Plug>(cokeline-switch-8)", description = "Buffer switch to 8", opts = silent },
    { "<Leader>9", "<Plug>(cokeline-switch-9)", description = "Buffer switch to 9", opts = silent },

    -- Dap
    {
      "<F1>",
      "<cmd>lua require('dap').toggle_breakpoint()<CR>",
      description = "Debug: Set breakpoint",
      opts = silent,
    },
    { "<F2>", "<cmd>lua require('dap').continue()<CR>", description = "Debug: Continue", opts = silent },
    { "<F3>", "<cmd>lua require('dap').step_into()<CR>", description = "Debug: Step into", opts = silent },
    { "<F4>", "<cmd>lua require('dap').step_over()<CR>", description = "Debug: Step over", opts = silent },
    {
      "<F5>",
      "<cmd>lua require('dap').repl.toggle({height = 6})<CR>",
      description = "Debug: Show REPL",
      opts = silent,
    },
    { "<F6>", "<cmd>lua require('dap').repl.run_last()<CR>", description = "Debug: Run last", opts = silent },
    {
      "<F9>",
      function()
        local _, dap = om.safe_require("dap")
        dap.disconnect()
        dap.close()
        dap.close()
      end,
      description = "Debug: Stop",
    },

    -- Focus
    {
      "<LocalLeader>ss",
      "<cmd>lua pcall(require('focus').split_nicely())<CR>",
      description = "Split",
      opts = silent,
    },
    {
      "<LocalLeader>sh",
      "<cmd>lua require('focus').split_command('h')<CR>",
      description = "Split: Left",
      opts = silent,
    },
    {
      "<LocalLeader>sj",
      "<cmd>lua require('focus').split_command('j')<CR>",
      description = "Split: Down",
      opts = silent,
    },
    {
      "<LocalLeader>sk",
      "<cmd>lua require('focus').split_command('k')<CR>",
      description = "Split: Up",
      opts = silent,
    },
    {
      "<LocalLeader>sl",
      "<cmd>lua require('focus').split_command('l')<CR>",
      description = "Split: Right",
      opts = silent,
    },

    -- Harpoon
    {
      "<LocalLeader>ha",
      '<cmd>lua require("harpoon.mark").add_file()<CR>',
      description = "Harpoon: Add file",
      opts = silent,
    },
    { "<LocalLeader>hl", "<cmd>Telescope harpoon marks<CR>", description = "Harpoon: List marks", opts = silent },
    {
      "<LocalLeader>hn",
      '<cmd>lua require("harpoon.ui"},.nav_next()<CR>',
      description = "Harpoon: Next mark",
      opts = silent,
    },
    {
      "<LocalLeader>hp",
      '<cmd>lua require("harpoon.ui").nav_prev()<CR>',
      description = "Harpoon: Previous mark",
      opts = silent,
    },
    {
      "<LocalLeader>h1",
      '<cmd>lua require("harpoon.ui").nav_file(1)<CR>',
      description = "Harpoon: Go to 1",
      opts = silent,
    },
    {
      "<LocalLeader>h2",
      '<cmd>lua require("harpoon.ui").nav_file(2)<CR>',
      description = "Harpoon: Go to 2",
      opts = silent,
    },
    {
      "<LocalLeader>h3",
      '<cmd>lua require("harpoon.ui").nav_file(3)<CR>',
      description = "Harpoon: Go to 3",
      opts = silent,
    },
    {
      "<LocalLeader>h4",
      '<cmd>lua require("harpoon.ui").nav_file(4)<CR>',
      description = "Harpoon: Go to 4",
      opts = silent,
    },
    {
      "<LocalLeader>h5",
      '<cmd>lua require("harpoon.ui").nav_file(5)<CR>',
      description = "Harpoon: Go to 5",
      opts = silent,
    },

    -- Hop
    { "s", "<cmd>lua require'hop'.hint_char1()<CR>", description = "Hop", mode = { "n", "o" } },
    -- File Explorer
    { "\\", "<cmd>NvimTreeToggle<CR>", description = "NvimTree: Toggle", opts = silent },
    { "<C-z>", "<cmd>NvimTreeFindFile<CR>", description = "NvimTree: Find File", opts = silent },

    -- Minimap
    {
      "<LocalLeader>m",
      function()
        vim.cmd("MinimapToggle")
        vim.cmd("MinimapRefresh")
      end,
      description = "Minimap toggle",
    },

    -- Neoclip
    {
      "<LocalLeader>p",
      "<cmd>lua require('telescope').extensions.neoclip.default()<CR>",
      description = "Neoclip",
      opts = silent,
    },

    -- Persisted
    { "<Leader>s", '<cmd>lua require("persisted").toggle()<CR>', description = "Session Toggle", opts = silent },

    -- QF Helper
    -- The '!' ensures that the cursor doesn't move to the QF or LL
    { "<Leader>q", "<cmd>QFToggle!<CR>", description = "Quickfix toggle", opts = silent },
    { "<Leader>l", "<cmd>LLToggle!<CR>", description = "Location List toggle", opts = silent },

    -- Search
    {
      "//",
      '<cmd>lua require("searchbox").match_all()<CR>',
      description = "Search",
      mode = { "n", "v" },
      opts = silent,
    },
    {
      "<LocalLeader>r",
      '<cmd>lua require("searchbox").replace()<CR>',
      description = "Search and replace",
      mode = { "n", "v" },
      opts = silent,
    },

    -- Telescope
    { "fd", h.lazy_required_fn("telescope.builtin", "diagnostics"), description = "Find diagnostics" },
    {
      "ff",
      h.lazy_required_fn("telescope.builtin", "find_files", { hidden = true }),
      description = "Find files",
    },
    { "fb", h.lazy_required_fn("telescope.builtin", "buffers"), description = "Find open buffers" },
    { "fp", "<cmd>Telescope project display_type=full<CR>", description = "Find projects" },
    {
      "<C-f>",
      h.lazy_required_fn("telescope.builtin", "current_buffer_fuzzy_find"),
      description = "Find in buffers",
    },
    {
      "<C-g>",
      h.lazy_required_fn("telescope.builtin", "live_grep", { path_display = "shorten", grep_open_files = true }),
      description = "Find in open files",
    },
    {
      "<Leader>g",
      h.lazy_required_fn("telescope.builtin", "live_grep", { path_display = "smart" }),
      description = "Find in pwd",
    },
    {
      "<Leader><Leader>",
      "<cmd>lua require('telescope').extensions.frecency.frecency()<CR>",
      description = "Find recent files",
    },

    -- Todo comments
    { "<Leader>c", "<cmd>TodoTelescope<CR>", description = "Todo comments", opts = silent },

    -- Toggleterm
    { "<C-x>", "<cmd>ToggleTerm<CR>", description = "Toggleterm", mode = { "n", "t" }, opts = silent },

    -- Treesitter Unit
    -- vau and viu select outer and inner units
    -- cau and ciu change outer and inner units
    -- vim.api.nvim_set_keymap("x", "iu", '<cmd>lua require"treesitter-unit".select()<CR>', silent)
    -- vim.api.nvim_set_keymap("x", "au", '<cmd>lua require"treesitter-unit".select(true)<CR>', silent)
    -- vim.api.nvim_set_keymap("o", "iu", '<cmd><c-u>lua require"treesitter-unit".select()<CR>', silent)
    -- vim.api.nvim_set_keymap("o", "au", '<cmd><c-u>lua require"treesitter-unit".select(true)<CR>', silent)

    -- Tmux
    {
      "<C-k>",
      "<cmd>lua require('tmux').move_up()<CR>",
      description = "Tmux: Move up",
    },
    {
      "<C-j>",
      "<cmd>lua require('tmux').move_down()<CR>",
      description = "Tmux: Move down",
    },
    {
      "<C-h>",
      "<cmd>lua require('tmux').move_left()<CR>",
      description = "Tmux: Move left",
    },
    {
      "<C-l>",
      "<cmd>lua require('tmux').move_right()<CR>",
      description = "Tmux: Move right",
    },

    -- Vim Test
    { "<Leader>t", "<cmd>TestNearest<CR>", description = "Test nearest" },
    { "<LocalLeader>ta", "<cmd>TestAll<CR>", description = "Test all" },
    { "<LocalLeader>tl", "<cmd>TestLast<CR>", description = "Test last" },
    { "<LocalLeader>tf", "<cmd>TestFile<CR>", description = "Test file" },
    { "<LocalLeader>ts", "<cmd>TestSuite<CR>", description = "Test suite" },

    -- Undotree
    { "<LocalLeader>u", "<cmd>UndotreeToggle<CR>", description = "Undotree toggle" },

    -- Yabs
    {
      "<LocalLeader>d",
      "<cmd>lua require('yabs'):run_default_task()<CR>",
      description = "Build file",
      opts = silent,
    },
  }
end

M.lsp_keymaps = function(client, bufnr)
  local h = require("legendary.helpers")
  local maps = {
    { "gd", vim.lsp.buf.definition, description = "LSP: Go to definition", opts = { buffer = bufnr } },
    {
      "gr",
      h.lazy_required_fn("telescope.builtin", "lsp_references"),
      description = "LSP: Find references",
      opts = { buffer = bufnr },
    },
    {
      "L",
      "<cmd>lua vim.diagnostic.open_float(0, { border = 'single', source = 'always' })<CR>",
      description = "LSP: Line diagnostics",
    },
    { "gh", vim.lsp.buf.hover, description = "LSP: Show hover information", opts = { buffer = bufnr } },
    {
      "<leader>p",
      h.lazy_required_fn("nvim-treesitter.textobjects.lsp_interop", "peek_definition_code", "@block.outer"),
      description = "LSP: Peek definition",
      opts = { buffer = bufnr },
    },
    { "F", vim.lsp.buf.code_action, description = "LSP: Show code actions", opts = { buffer = bufnr } },
    { "[", vim.diagnostic.goto_prev, description = "LSP: Go to previous diagnostic item", opts = { buffer = bufnr } },
    { "]", vim.diagnostic.goto_next, description = "LSP: Go to next diagnostic item", opts = { buffer = bufnr } },
  }

  if client.resolved_capabilities.implementation then
    table.insert(maps, {
      "gi",
      vim.lsp.buf.implementation,
      description = "LSP: Go to implementation",
      opts = { buffer = bufnr },
    })
  end
  if client.resolved_capabilities.type_definition then
    table.insert(
      maps,
      { "gt", vim.lsp.buf.type_definition, description = "LSP: Go to type definition", opts = { buffer = bufnr } }
    )
  end
  if client.supports_method("textDocument/rename") then
    table.insert(
      maps,
      { "<leader>rn", vim.lsp.buf.rename, description = "LSP: Rename symbol", opts = { buffer = bufnr } }
    )
  end
  if client.supports_method("textDocument/signatureHelp") then
    table.insert(
      maps,
      { "gs", vim.lsp.buf.signature_help, description = "LSP: Show signature help", opts = { buffer = bufnr } }
    )
  end

  local lsps_that_can_format = { ["null-ls"] = true, solargraph = true }

  if om.contains(lsps_that_can_format, client.name) and client.resolved_capabilities.document_formatting then
    -- om.augroup("LspFormat", {
    --     {
    --         events = { "BufWritePre" },
    --         targets = { "<buffer>" },
    --         command = vim.lsp.buf.formatting_sync,
    --     },
    -- })
    table.insert(
      maps,
      { "<LocalLeader>lf", vim.lsp.buf.formatting, description = "LSP: Format", opts = { buffer = bufnr } }
    )
  else
    client.resolved_capabilities.document_formatting = false
  end

  local ok, lightbulb = om.safe_require("nvim-lightbulb")
  if ok then
    lightbulb.setup({
      sign = {
        enabled = false,
      },
      float = {
        enabled = true,
      },
    })
    om.augroup("LspCodeAction", {
      {
        events = { "CursorHold", "CursorHoldI" },
        targets = { "<buffer>" },
        command = function()
          lightbulb.update_lightbulb()
        end,
      },
    })
  end

  -- List of LSP servers that we allow to format
  return maps
end
---------------------------------------------------------------------------- }}}
return M
