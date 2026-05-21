-- lua/plugins/luasnip.lua
return {
  "L3MON4D3/LuaSnip",
  event = "InsertEnter",
  dependencies = {
    "rafamadriz/friendly-snippets",  -- 便利なスニペット集（任意）
  },
  config = function()
    require("luasnip.loaders.from_vscode").lazy_load()
  end,
}
