return {
	"lukas-reineke/indent-blankline.nvim",
	event = "VeryLazy",
	main = "ibl",
	opts = {
		indent = {
			char = "│", -- 通常のインデント文字
			tab_char = "│", -- タブ文字の表示
		},
		scope = {
			show_start = false, -- スコープの開始を非表示
			show_end = false, -- スコープの終了を非表示
		},
	},
}
