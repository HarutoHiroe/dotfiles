return {
  "shellRaining/hlchunk.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("hlchunk").setup({
      chunk = {
        enable = true,
        use_treesitter = false,
        delay = 50,
        duration = 100,
		 chars = {
		 horizontal_line = "═",
		 vertical_line = "║",
		 left_top = "╔",
		 left_bottom = "╚",
		 right_arrow = "►",
		 },
       style = {
          { fg = "#4a90d9" },  -- 青
          { fg = "#c9a0dc" },  -- エラー時: 薄紫
        },
      },
      indent = {
        enable = true,
        use_treesitter = false,
        chars = {
          "│",
        },
        style = {
          { fg = "#6fa8dc" },  -- 水色
        },
      },
      line_num = {
        enable = true,
        use_treesitter = false,
        style = "#a4c2f4",  -- 明るい水色
      },
      blank = {
        enable = false,
      },
    })
  end,
}

