-- 基本設定
vim.opt.termguicolors = true    -- 24ビットRGBカラー有効化
vim.opt.scrolloff = 4           -- ファイル末尾に移動した際に4行分の余白設定
vim.opt.ignorecase = true       -- 検索時に大文字小文字無視
vim.opt.smartcase = true        -- 検索時に大文字が含まれていたらignorecaseを無効化
vim.opt.inccommand = 'split'    -- 置換時に画面下部に検索結果を表示
vim.opt.clipboard = 'unnamedplus' -- クリップボードの有効化

-- ウィンドウ設定
vim.opt.number = true           -- 行番号表示
vim.opt.relativenumber = true   -- 相対行番号表示
vim.opt.cursorline = true       -- カーソル行を強調
vim.opt.signcolumn = 'yes:1'    -- 標識のためのスペースを最左列に設ける
vim.opt.wrap = false            -- テキストの折り返しを無効化
vim.opt.list = true             -- 非表示文字の可視化
-- vim.opt.colorcolumn = '100'  -- 指定したカラム列を強調

-- バッファ設定
vim.opt.swapfile = false        -- swapfile作成を無効化
vim.opt.tabstop = 4             -- tab幅
vim.opt.expandtab = false        -- tabをスペースに変換
vim.opt.shiftwidth = 0          -- オートインデントをtabstopの値に

-- 背景透過設定
vim.api.nvim_set_hl(0, 'Normal', { bg = 'NONE' })
vim.api.nvim_set_hl(0, 'NormalNC', { bg = 'NONE' })
vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'NONE' })
vim.api.nvim_set_hl(0, 'SignColumn', { bg = 'NONE' })
vim.api.nvim_set_hl(0, 'EndOfBuffer', { bg = 'NONE' })
