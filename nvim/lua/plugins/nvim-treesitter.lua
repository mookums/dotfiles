require('nvim-treesitter.configs').setup({
	ensure_installed = {
		"bash",
		"c",
		"lua",
		"ocaml",
		"go",
		"java",
		"javascript",
		"typescript",
		"zig"
	},
	sync_install = false,
	auto_install = true,

	highlight = {
		enable = true,

		additional_vim_regex_highlighting = false,
	},
})
