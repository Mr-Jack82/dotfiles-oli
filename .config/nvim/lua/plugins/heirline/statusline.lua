local utils = require("heirline.utils")
local conditions = require("heirline.conditions")

local LeftSlantStart = {
  provider = "",
  hl = { fg = "bg", bg = "statusline_bg" },
}
local LeftSlantEnd = {
  provider = "",
  hl = { fg = "statusline_bg", bg = "bg" },
}
local RightSlantStart = {
  provider = "",
  hl = { fg = "statusline_bg", bg = "bg" },
}
local RightSlantEnd = {
  provider = "",
  hl = { fg = "bg", bg = "statusline_bg" },
}

local VimMode = {
  init = function(self)
    self.mode = vim.fn.mode(1)
    self.mode_color = self.mode_colors[self.mode:sub(1, 1)]
  end,
  update = {
    "ModeChanged",
    pattern = "*:*",
    callback = vim.schedule_wrap(function()
      vim.cmd("redrawstatus")
    end),
  },
  static = {
    mode_names = {
      n = "NORMAL",
      no = "NORMAL",
      nov = "NORMAL",
      noV = "NORMAL",
      ["no\22"] = "NORMAL",
      niI = "NORMAL",
      niR = "NORMAL",
      niV = "NORMAL",
      nt = "NORMAL",
      v = "VISUAL",
      vs = "VISUAL",
      V = "VISUAL",
      Vs = "VISUAL",
      ["\22"] = "VISUAL",
      ["\22s"] = "VISUAL",
      s = "SELECT",
      S = "SELECT",
      ["\19"] = "SELECT",
      i = "INSERT",
      ic = "INSERT",
      ix = "INSERT",
      R = "REPLACE",
      Rc = "REPLACE",
      Rx = "REPLACE",
      Rv = "REPLACE",
      Rvc = "REPLACE",
      Rvx = "REPLACE",
      c = "COMMAND",
      cv = "Ex",
      r = "...",
      rm = "M",
      ["r?"] = "?",
      ["!"] = "!",
      t = "TERM",
    },
    mode_colors = {
      n = "purple",
      i = "green",
      v = "orange",
      V = "orange",
      ["\22"] = "orange",
      c = "orange",
      s = "yellow",
      S = "yellow",
      ["\19"] = "yellow",
      r = "green",
      R = "green",
      ["!"] = "red",
      t = "red",
    },
  },
  {
    provider = function(self)
      return " %2(" .. self.mode_names[self.mode] .. "%) "
    end,
    hl = function(self)
      return { fg = "bg", bg = self.mode_color }
    end,
    on_click = {
      callback = function()
        vim.cmd("Alpha")
      end,
      name = "heirline_mode",
    },
  },
  {
    provider = "",
    hl = function(self)
      return { fg = self.mode_color, bg = "bg" }
    end,
  },
}

local GitBranch = {
  condition = conditions.is_git_repo,
  init = function(self)
    self.status_dict = vim.b.gitsigns_status_dict
  end,
  {
    condition = function(self)
      return not conditions.buffer_matches({
        filetype = self.filetypes,
      })
    end,
    LeftSlantStart,
    {
      provider = function(self)
        return "  " .. (self.status_dict.head == "" and "main" or self.status_dict.head) .. " "
      end,
      on_click = {
        callback = function()
          om.ListBranches()
        end,
        name = "git_change_branch",
      },
      hl = { fg = "gray", bg = "statusline_bg" },
    },
    {
      condition = function()
        return (_G.GitStatus ~= nil and (_G.GitStatus.ahead ~= 0 or _G.GitStatus.behind ~= 0))
      end,
      update = { "User", pattern = "GitStatusChanged" },
      {
        condition = function()
          return _G.GitStatus.status == "pending"
        end,
        provider = " ",
        hl = { fg = "gray", bg = "statusline_bg" },
      },
      {
        provider = function()
          return _G.GitStatus.behind .. " "
        end,
        hl = function()
          return { fg = _G.GitStatus.behind == 0 and "gray" or "red", bg = "statusline_bg" }
        end,
        on_click = {
          callback = function()
            if _G.GitStatus.behind > 0 then
              om.GitPull()
            end
          end,
          name = "git_pull",
        },
      },
      {
        provider = function()
          return _G.GitStatus.ahead .. " "
        end,
        hl = function()
          return { fg = _G.GitStatus.ahead == 0 and "gray" or "green", bg = "statusline_bg" }
        end,
        on_click = {
          callback = function()
            if _G.GitStatus.ahead > 0 then
              om.GitPush()
            end
          end,
          name = "git_push",
        },
      },
    },
    LeftSlantEnd,
  },
}

local FileBlock = {
  init = function(self)
    self.filename = vim.api.nvim_buf_get_name(0)
  end,
  condition = function(self)
    return not conditions.buffer_matches({
      filetype = self.filetypes,
    })
  end,
}

local FileName = {
  provider = function(self)
    local filename = vim.fn.fnamemodify(self.filename, ":t")
    if filename == "" then
      return "[No Name]"
    end
    return " " .. filename .. " "
  end,
  on_click = {
    callback = function()
      vim.cmd("Telescope find_files")
    end,
    name = "find_files",
  },
  hl = { fg = "gray", bg = "statusline_bg" },
}

local FileFlags = {
  -- {
  --   condition = function() return vim.bo.modified end,
  --   provider = " ",
  --   hl = { fg = "gray" },
  -- },
  {
    condition = function()
      return not vim.bo.modifiable or vim.bo.readonly
    end,
    provider = " ",
    hl = { fg = "gray" },
  },
}

local FileNameBlock = utils.insert(FileBlock, LeftSlantStart, utils.insert(FileName, FileFlags), LeftSlantEnd)

---Return the LspDiagnostics from the LSP servers
local LspDiagnostics = {
  condition = conditions.has_diagnostics,
  init = function(self)
    self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
    self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
    self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
    self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
  end,
  on_click = {
    callback = function()
      require("telescope.builtin").diagnostics({
        layout_strategy = "center",
        bufnr = 0,
      })
    end,
    name = "heirline_diagnostics",
  },
  update = { "DiagnosticChanged", "BufEnter" },
  -- Errors
  {
    condition = function(self)
      return self.errors > 0
    end,
    hl = { fg = "bg", bg = "red" },
    {
      {
        provider = "",
      },
      {
        provider = function(self)
          return vim.fn.sign_getdefined("DiagnosticSignError")[1].text .. self.errors
        end,
      },
      {
        provider = "",
        hl = { bg = "bg", fg = "red" },
      },
    },
  },
  -- Warnings
  {
    condition = function(self)
      return self.warnings > 0
    end,
    hl = { fg = "bg", bg = "yellow" },
    {
      {
        provider = "",
      },
      {
        provider = function(self)
          return vim.fn.sign_getdefined("DiagnosticSignWarn")[1].text .. self.warnings
        end,
      },
      {
        provider = "",
        hl = { bg = "bg", fg = "yellow" },
      },
    },
  },
  -- Hints
  {
    condition = function(self)
      return self.hints > 0
    end,
    hl = { fg = "gray", bg = "bg" },
    {
      {
        provider = function(self)
          return " " .. vim.fn.sign_getdefined("DiagnosticSignHint")[1].text .. self.hints
        end,
      },
    },
  },
  -- Info
  {
    condition = function(self)
      return self.info > 0
    end,
    hl = { fg = "gray", bg = "bg" },
    {
      {
        provider = function(self)
          return " " .. vim.fn.sign_getdefined("DiagnosticSignInfo")[1].text .. self.info
        end,
      },
    },
  },
}

local LspAttached = {
  condition = conditions.lsp_attached,
  static = {
    lsp_attached = false,
    show_lsps = {
      copilot = false,
      efm = false,
    },
  },
  init = function(self)
    for i, server in pairs(vim.lsp.get_active_clients({ bufnr = 0 })) do
      if self.show_lsps[server.name] ~= false then
        self.lsp_attached = true
        return
      end
    end
  end,
  update = { "LspAttach", "LspDetach" },
  on_click = {
    callback = function()
      vim.defer_fn(function()
        vim.cmd("LspInfo")
      end, 100)
    end,
    name = "heirline_LSP",
  },
  {
    condition = function(self)
      return self.lsp_attached
    end,
    LeftSlantStart,
    {
      provider = "  ",
      hl = { fg = "gray", bg = "statusline_bg" },
    },
    LeftSlantEnd,
  },
}

---Return the current line number as a % of total lines and the total lines in the file
local Ruler = {
  condition = function(self)
    return not conditions.buffer_matches({
      filetype = self.filetypes,
    })
  end,
  {
    provider = "",
    hl = { fg = "gray", bg = "bg" },
  },
  {
    -- %L = number of lines in the buffer
    -- %P = percentage through file of displayed window
    provider = " %P% /%2L ",
    hl = { fg = "bg", bg = "gray" },
    on_click = {
      callback = function()
        local line = vim.api.nvim_win_get_cursor(0)[1]
        local total_lines = vim.api.nvim_buf_line_count(0)

        if math.floor((line / total_lines)) > 0.5 then
          vim.cmd("normal! gg")
        else
          vim.cmd("normal! G")
        end
      end,
      name = "heirline_ruler",
    },
  },
}

local MacroRecording = {
  condition = function(self)
    return vim.fn.reg_recording() ~= ""
  end,
  update = {
    "RecordingEnter",
    "RecordingLeave",
  },
  {
    provider = "",
    hl = { fg = "blue", bg = "bg" },
  },
  {
    provider = function(self)
      return " " .. vim.fn.reg_recording() .. " "
    end,
    hl = { bg = "blue", fg = "bg" },
  },
  {
    provider = "",
    hl = { fg = "bg", bg = "blue" },
  },
}

local SearchResults = {
  condition = function(self)
    return vim.v.hlsearch ~= 0
  end,
  init = function(self)
    local ok, search = pcall(vim.fn.searchcount)
    if ok and search.total then
      self.search = search
    end
  end,
  {
    provider = "",
    hl = function()
      return { fg = utils.get_highlight("Substitute").bg, bg = "bg" }
    end,
  },
  {
    provider = function(self)
      local search = self.search

      return string.format(" %d/%d ", search.current, math.min(search.total, search.maxcount))
    end,
    hl = function()
      return { bg = utils.get_highlight("Substitute").bg, fg = "bg" }
    end,
  },
  {
    provider = "",
    hl = function()
      return { bg = utils.get_highlight("Substitute").bg, fg = "bg" }
    end,
  },
}

---Return the status of the current session
local Session = {
  update = { "User", pattern = "PersistedStateChange" },
  {
    condition = function(self)
      return not conditions.buffer_matches({
        filetype = self.filetypes,
      })
    end,
    RightSlantStart,
    {
      provider = function(self)
        if vim.g.persisting then
          return "   "
        else
          return "   "
        end
      end,
      hl = { fg = "gray", bg = "statusline_bg" },
      update = {
        "User",
        pattern = "PersistedToggled",
        callback = vim.schedule_wrap(function()
          vim.cmd("redrawstatus")
        end),
      },
      on_click = {
        callback = function()
          vim.cmd("SessionToggle")
        end,
        name = "toggle_session",
      },
    },
    RightSlantEnd,
  },
}

local Overseer = {
  condition = function()
    local ok, _ = om.safe_require("overseer")
    if ok then
      return true
    end
  end,
  init = function(self)
    self.overseer = require("overseer")
    self.tasks = self.overseer.task_list
    self.STATUS = self.overseer.constants.STATUS
  end,
  static = {
    symbols = {
      ["FAILURE"] = "  ",
      ["CANCELED"] = "  ",
      ["SUCCESS"] = "  ",
      ["RUNNING"] = " 省",
    },
    colors = {
      ["FAILURE"] = "red",
      ["CANCELED"] = "gray",
      ["SUCCESS"] = "green",
      ["RUNNING"] = "yellow",
    },
  },
  {
    condition = function(self)
      return #self.tasks.list_tasks() > 0
    end,
    {
      provider = function(self)
        local tasks_by_status = self.overseer.util.tbl_group_by(self.tasks.list_tasks({ unique = true }), "status")

        for _, status in ipairs(self.STATUS.values) do
          local status_tasks = tasks_by_status[status]
          if self.symbols[status] and status_tasks then
            self.color = self.colors[status]
            return self.symbols[status]
          end
        end
      end,
      hl = function(self)
        return { fg = self.color }
      end,
      on_click = {
        callback = function()
          require("neotest").run.run_last()
        end,
        name = "run_last_test",
      },
    },
  },
}

local Dap = {
  condition = function()
    local session = require("dap").session()
    return session ~= nil
  end,
  provider = function()
    return "  "
  end,
  on_click = {
    callback = function()
      require("dap").continue()
    end,
    name = "dap_continue",
  },
  hl = { fg = "red" },
}

-- Show plugin updates available from lazy.nvim
local Lazy = {
  condition = function(self)
    return not conditions.buffer_matches({
      filetype = self.filetypes,
    }) and require("lazy.status").has_updates()
  end,
  -- update = { "User", pattern = "LazyUpdate" },
  provider = function()
    return "  " .. require("lazy.status").updates() .. " "
  end,
  on_click = {
    callback = function()
      require("lazy").update()
    end,
    name = "update_plugins",
  },
  hl = { fg = "gray" },
}

--- Return information on the current buffers filetype
local FileIcon = {
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ":e")
    self.icon, self.icon_color = require("nvim-web-devicons").get_icon_color(filename, extension, { default = true })
  end,
  provider = function(self)
    return self.icon and (" " .. self.icon .. " ")
  end,
  on_click = {
    callback = function()
      om.ChangeFiletype()
    end,
    name = "change_ft",
  },
  hl = { fg = "gray", bg = "statusline_bg" },
}

local FileType = {
  provider = function()
    return string.lower(vim.bo.filetype) .. " "
  end,
  on_click = {
    callback = function()
      om.ChangeFiletype()
    end,
    name = "change_ft",
  },
  hl = { fg = "gray", bg = "statusline_bg" },
}

local FileType = utils.insert(FileBlock, RightSlantStart, FileIcon, FileType, RightSlantEnd)

--- Return information on the current file's encoding
local FileEncoding = {
  condition = function(self)
    return not conditions.buffer_matches({
      filetype = self.filetypes,
    })
  end,
  RightSlantStart,
  {
    provider = function()
      local enc = (vim.bo.fenc ~= "" and vim.bo.fenc) or vim.o.enc -- :h 'enc'
      return " " .. enc .. " "
    end,
    hl = {
      fg = "gray",
      bg = "statusline_bg",
    },
  },
  RightSlantEnd,
}

return {
  static = {
    filetypes = {
      "^git.*",
      "fugitive",
      "alpha",
      "^neo--tree$",
      "^neotest--summary$",
      "^neo--tree--popup$",
      "^NvimTree$",
      "^toggleterm$",
    },
    force_inactive_filetypes = {
      "^aerial$",
      "^alpha$",
      "^chatgpt$",
      "^DressingInput$",
      "^frecency$",
      "^lazy$",
      "^lazyterm$",
      "^netrw$",
      "^oil$",
      "^TelescopePrompt$",
      "^undotree$",
    },
  },
  condition = function(self)
    return not conditions.buffer_matches({
      filetype = self.force_inactive_filetypes,
    })
  end,
  {
    VimMode,
    GitBranch,
    -- FileNameBlock,
    LspAttached,
    -- LspDiagnostics,
    { provider = "%=" },
    Overseer,
    Dap,
    Lazy,
    FileType,
    -- FileEncoding,
    Session,
    MacroRecording,
    SearchResults,
    Ruler,
  },
}
