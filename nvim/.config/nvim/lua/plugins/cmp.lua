return {
	"hrsh7th/nvim-cmp",
	event = "VeryLazy",
	config = function()
		local cmp = require("cmp")
		local luasnip = require("luasnip")

		cmp.setup({
			snippet = {
				expand = function(args)
					luasnip.lsp_expand(args.body) -- スニペットを展開
				end,
			},
			mapping = cmp.mapping.preset.insert({
				["<C-p>"] = cmp.mapping.scroll_docs(-4), -- ドキュメントを上にスクロール
				["<C-n>"] = cmp.mapping.scroll_docs(4), -- ドキュメントを下にスクロール
				["<C-Space>"] = cmp.mapping.complete(), -- 補完をトリガー
				["<C-e>"] = cmp.mapping.abort(), -- 補完をキャンセル
				["<CR>"] = cmp.mapping.confirm({ select = true }), -- 補完を確定
			}),
			sources = {
				{ name = "nvim_lsp" }, -- LSP からの補完
				{ name = "luasnip" }, -- スニペットからの補完
				{ name = "buffer" }, -- バッファからの補完
				{ name = "path" }, -- パスからの補完
				{ name = "cmdline" }, -- コマンドラインからの補完
			},
			window = {
				completion = {
					border = "rounded", -- 補完ウィンドウの枠を丸くする
					max_height = 6, -- 最大高さを設定
				},
			},
		})

		-- コマンドラインの補完設定
		cmp.setup.cmdline("/", {
			mapping = cmp.mapping.preset.cmdline(),
			sources = {
				{ name = "buffer" }, -- バッファからの補完
			},
		})

		cmp.setup.cmdline(":", {
			mapping = cmp.mapping.preset.cmdline(),
			sources = cmp.config.sources({
				{ name = "path" }, -- パスからの補完
			}, {
				{ name = "cmdline" }, -- コマンドラインからの補完
			}),
		})
	end,
}
