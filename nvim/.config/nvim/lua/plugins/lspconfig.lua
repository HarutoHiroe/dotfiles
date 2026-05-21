return {
	"neovim/nvim-lspconfig",
	event = "VeryLazy",
	config = function()
		-- TypeScript & JavaScript
		vim.lsp.config.ts_ls = {
			cmd = { "typescript-language-server", "--stdio" },
			filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
			root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
		}
		-- CSS
		vim.lsp.config.cssls = {
			cmd = { "vscode-css-language-server", "--stdio" },
			filetypes = { "css", "scss", "less" },
			root_markers = { "package.json", ".git" },
			settings = {
				css = { validate = true },
				scss = { validate = true },
				less = { validate = true },
			},
		}
		-- HTML
		vim.lsp.config.html = {
			cmd = { "vscode-html-language-server", "--stdio" },
			filetypes = { "html" },
			root_markers = { "package.json", ".git" },
			init_options = {
				configurationSection = { "html", "css", "javascript" },
				embeddedLanguages = {
					css = true,
					javascript = true,
				},
			},
		}
		-- Astro
		vim.lsp.config.astro = {
			cmd = { "astro-ls", "--stdio" },
			filetypes = { "astro" },
			root_markers = { "package.json", "astro.config.mjs", ".git" },
		}
		-- Lua
		vim.lsp.config.lua_ls = {
			cmd = { "lua-language-server" },
			filetypes = { "lua" },
			root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
			settings = {
				Lua = {
					runtime = {
						version = "LuaJIT",
					},
					diagnostics = {
						globals = { "vim" },
					},
					workspace = {
						library = vim.api.nvim_get_runtime_file("", true),
						checkThirdParty = false,
					},
					telemetry = {
						enable = false,
					},
				},
			},
		}
		-- C / C++
		vim.lsp.config.clangd = {
			cmd = { "clangd", "--background-index", "--clang-tidy" },
			filetypes = { "c", "cpp", "objc", "objcpp" },
			root_markers = { "compile_commands.json", ".clangd", ".git" },
		}
		-- Rust
		vim.lsp.config.rust_analyzer = {
			cmd = { "rust-analyzer" },
			filetypes = { "rust" },
			root_markers = { "Cargo.toml", ".git" },
			settings = {
				["rust-analyzer"] = {
					cargo = {
						allFeatures = true,
					},
					checkOnSave = {
						command = "clippy",
					},
				},
			},
		}
		-- Python
		vim.lsp.config.pyright = {
			cmd = { "pyright-langserver", "--stdio" },
			filetypes = { "python" },
			root_markers = { "pyproject.toml", "setup.py", "requirements.txt", ".git" },
			settings = {
				python = {
					analysis = {
						typeCheckingMode = "basic",
						autoSearchPaths = true,
						useLibraryCodeForTypes = true,
					},
				},
			},
		}
		-- Java
		vim.lsp.config.jdtls = {
			cmd = { "jdtls" },
			filetypes = { "java" },
			root_markers = { "pom.xml", "build.gradle", ".git" },
		}

		-- LSPを有効化
		vim.lsp.enable({
			"ts_ls",
			"cssls",
			"html",
			"astro",
			"lua_ls",
			"clangd",
			"rust_analyzer",
			"pyright",
			"jdtls",
		})

		-- Diagnostic設定
		vim.diagnostic.config({
			virtual_text = true,
			signs = true,
			float = { border = "rounded" },
		})

		-- キーマッピング
		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function(event)
				local opts = { buffer = event.buf }
				vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
				vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
				vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
				vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
				vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
				vim.keymap.set("n", "<leader>h", vim.lsp.buf.document_highlight, opts)
				vim.keymap.set("n", "<leader>H", vim.lsp.buf.clear_references, opts)
				vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
				vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
				vim.keymap.set("n", "ga", vim.lsp.buf.code_action, opts)
				vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
				vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
				vim.keymap.set("n", "<leader>f", function()
					vim.lsp.buf.format({ async = true })
				end, opts)
			end,
		})
	end,
}
