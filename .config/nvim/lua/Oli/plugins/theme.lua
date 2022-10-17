---@diagnostic disable: need-check-nil
local M = {}

M.setup = function()
  local ok, onedarkpro = pcall(load, "onedarkpro")
  if not ok then
    return
  end

  onedarkpro.setup({
    log_level = "debug",
    -- caching = true,
    plugins = {
      barbar = false,
      lsp_saga = false,
      marks = false,
      polygot = false,
      startify = false,
      telescope = false,
      trouble = false,
      vim_ultest = false,
      which_key = false,
    },
    styles = {
      comments = "italic",
      conditionals = "italic",
      operators = "italic",
      keywords = "italic",
      virtual_text = "italic,underline",
    },
    options = {
      -- bold = true,
      -- italic = true,
      -- underline = true,
      -- undercurl = true,

      cursorline = true,
      -- terminal_colors = true,
      -- transparency = true,
    },
    colors = {
      onedark = {
        vim = "#81b766", -- green
        brackets = "#abb2bf", -- fg / gray
        cursorline = "#2e323b",
        indentline = "#3c414d",

        ghost_text = "#555961",

        bufferline_text_focus = "#949aa2",

        statusline_bg = "#2e323b", -- gray

        telescope_prompt = "#2e323a",
        telescope_results = "#21252d",
      },
      onelight = {
        vim = "#029632", -- green
        brackets = "#e05661", -- red
        scrollbar = "#eeeeee",

        ghost_text = "#c3c3c3",

        statusline_bg = "#f0f0f0", -- gray

        telescope_prompt = "#f5f5f5",
        telescope_results = "#eeeeee",
      },
    },
    highlights = {
      -- Editor
      BufferlineOffset = { fg = "${purple}", style = "bold" },
      CursorLineNR = {
        bg = "${cursorline}",
        fg = "${purple}",
        style = "bold",
      },
      DiffChange = { style = "underline" }, -- diff mode: Changed line |diff.txt|
      MatchParen = { fg = "${cyan}", style = "underline" },
      ModeMsg = { link = "LineNr" }, -- Make command line text lighter
      Search = { bg = "${selection}", fg = "${yellow}", style = "underline" },
      StatusLine = { bg = "NONE", fg = "NONE" },

      -- Highlight brackets with a custom color
      -- TSPunctBracket = { fg = "${brackets}" },
      -- TSPunctSpecial = { fg = "${brackets}" },

      -- Aerial plugin
      AerialClass = { fg = "${purple}", style = "bold,italic" },
      AerialClassIcon = { fg = "${purple}" },
      AerialConstructorIcon = { fg = "${yellow}" },
      AerialEnumIcon = { fg = "${blue}" },
      AerialFunctionIcon = { fg = "${red}" },
      AerialInterfaceIcon = { fg = "${orange}" },
      AerialMethodIcon = { fg = "${green}" },
      AerialStructIcon = { fg = "${cyan}" },

      -- Alpha (dashboard) plugin
      AlphaHeader = {
        fg = (vim.o.background == "dark" and "${green}" or "${red}"),
      },
      AlphaButtonText = {
        fg = "${blue}",
        style = "bold",
      },
      AlphaButtonShortcut = {
        fg = (vim.o.background == "dark" and "${green}" or "${yellow}"),
        style = "italic,bold",
      },
      AlphaFooter = { fg = "${gray}", style = "italic" },

      -- Cmp
      CmpItemAbbrMatch = { fg = "${blue}", style = "bold" },
      CmpItemAbbrMatchFuzzy = { fg = "${blue}", style = "underline" },
      GhostText = { fg = "${ghost_text}" },

      -- Copilot
      CopilotSuggestion = { fg = "${gray}", style = "italic" },

      -- DAP
      DebugBreakpointLine = { fg = "${red}", style = "underline" },
      DebugHighlightLine = { fg = "${purple}", style = "italic" },
      NvimDapVirtualText = { fg = "${cyan}", style = "italic" },

      -- DAP UI
      DapUIBreakpointsCurrentLine = { fg = "${yellow}", style = "bold" },

      -- Fidget plugin
      FidgetTitle = { fg = "${purple}" },
      FidgetTask = { fg = "${gray}" },

      -- Luasnip
      LuaSnipChoiceNode = { fg = "${yellow}" },
      LuaSnipInsertNode = { fg = "${yellow}" },

      -- Minimap
      MapBase = { fg = "${gray}" },
      MapCursor = { fg = "${purple}", bg = "${cursorline}" },
      -- MapRange = { fg = "${fg}" },

      -- Navic
      NavicText = { fg = "${gray}", style = "italic" },

      -- Neotest
      NeotestAdapterName = { fg = "${purple}", style = "bold" },
      NeotestFocused = { style = "bold" },
      NeotestNamespace = { fg = "${blue}", style = "bold" },

      -- Neotree
      NeoTreeRootName = { fg = "${purple}", style = "bold" },
      NeoTreeFileNameOpened = { fg = "${purple}", style = "italic" },

      -- Telescope
      TelescopeBorder = {
        fg = "${telescope_results}",
        bg = "${telescope_results}",
      },
      TelescopePromptBorder = {
        fg = "${telescope_prompt}",
        bg = "${telescope_prompt}",
      },
      TelescopePromptCounter = { fg = "${fg}" },
      TelescopePromptNormal = { fg = "${fg}", bg = "${telescope_prompt}" },
      TelescopePromptPrefix = {
        fg = "${purple}",
        bg = "${telescope_prompt}",
      },
      TelescopePromptTitle = {
        fg = "${telescope_prompt}",
        bg = "${purple}",
      },

      TelescopePreviewTitle = {
        fg = "${telescope_results}",
        bg = "${green}",
      },
      TelescopeResultsTitle = {
        fg = "${telescope_results}",
        bg = "${telescope_results}",
      },

      TelescopeMatching = { fg = "${blue}" },
      TelescopeNormal = { bg = "${telescope_results}" },
      TelescopeSelection = { bg = "${telescope_prompt}" },

      -- Todo Comments:
      TodoTest = { fg = "${purple}" },
      TodoPerf = { fg = "${purple}" },
    },
  })
  vim.cmd("colorscheme onedarkpro")
end
return M
