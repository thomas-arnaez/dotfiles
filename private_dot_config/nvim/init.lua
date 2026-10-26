vim.loader.enable()

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable netrw because nvim-tree replaces it
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- ============================================================
-- Options
-- ============================================================

local opt = vim.opt

vim.opt.exrc = true

opt.number = true
opt.termguicolors = true
opt.signcolumn = "yes"

opt.expandtab = false
opt.tabstop = 4
opt.shiftwidth = 4

opt.splitright = true
opt.splitbelow = true

opt.ignorecase = true
opt.smartcase = true

opt.updatetime = 250
opt.clipboard = "unnamedplus"

-- ============================================================
-- Plugins
-- ============================================================

vim.pack.add({
    { src = "https://github.com/nvim-lua/plenary.nvim" },
    { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
    { src = "https://github.com/catppuccin/nvim" },
    { src = "https://github.com/nvim-tree/nvim-web-devicons" },
    { src = "https://github.com/nvim-tree/nvim-tree.lua" },
    { src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/ibhagwan/fzf-lua" },
	{ src=  "https://github.com/dlyongemallo/diffview-plus.nvim" },
	{ src = "https://github.com/lewis6991/gitsigns.nvim" },
    { src = "https://github.com/mrjones2014/smart-splits.nvim" },
	{ src = "https://github.com/smart-splits-nvim/backend-zellij-lua" },
	{ src = "https://github.com/mfussenegger/nvim-dap" },
	{ src = "https://github.com/igorlfs/nvim-dap-view" },
	{ src = "https://github.com/sudo-tee/opencode.nvim" },
	{ src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
	{ src = "https://github.com/Saghen/blink.lib" },
	{ src = "https://github.com/Saghen/blink.cmp" },
}, {
    confirm = true,
})


-- ============================================================
-- Theme
-- ============================================================

require("catppuccin").setup({})

vim.cmd.colorscheme("catppuccin")

-- ============================================================
-- Treesitter
-- ============================================================

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("user.treesitter", {
        clear = true,
    }),

    pattern = { "c", "cpp", "asm", "lua", "cmake", "make", "rust" },

    callback = function(ev)
        vim.treesitter.start(ev.buf)
    end,
})

-- ============================================================
-- Diagnostics
-- ============================================================

vim.diagnostic.config({
	severity_sort = true,
	update_in_insert = false,
	virtual_text = false,
	virtual_lines = {
		current_line = true
	},
	float = {
		border = "rounded",
		source = true
	},
})

-- ============================================================
-- LSP
-- ============================================================

vim.lsp.config("clangd", {
    cmd = {
		"clangd",
        "--background-index",
        "--clang-tidy"
    },
})

vim.lsp.enable("ts_ls")

vim.lsp.enable("eslint")

local lsp_group = vim.api.nvim_create_augroup("user.lsp", {
    clear = true,
})

vim.api.nvim_create_autocmd("LspAttach", {
    group = lsp_group,

    callback = function(ev)
        local opts = {
            buffer = ev.buf,
            silent = true,
        }

        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

        local client = vim.lsp.get_client_by_id(ev.data.client_id)

        if client and client.name == "clangd" then
            vim.keymap.set("n", "<leader>cf", function()
                vim.lsp.buf.format({
                    bufnr = ev.buf,
                    id = client.id,
                    timeout_ms = 2000,
                })
            end, {
                buffer = ev.buf,
                silent = true,
                desc = "Format C/C++ buffer",
            })
        end
    end,
})

vim.lsp.enable("clangd")

vim.lsp.config("rust_analyzer", {
    settings = {
        ["rust-analyzer"] = {
            check = {
                command = "clippy",
            },
        },
    },
})

vim.lsp.enable("rust_analyzer")

-- ============================================================
-- Completion
-- ============================================================

local blink = require("blink.cmp")

blink.build():pwait()

blink.setup({
    keymap = {
        preset = "default",
    },

    completion = {
        documentation = {
            auto_show = true,
            auto_show_delay_ms = 500,
        },
    },

    sources = {
        default = {
            "lsp",
            "path",
            "snippets",
            "buffer",
        },
    },

    fuzzy = {
        implementation = "rust",
    },
})

-- ============================================================
-- dap
-- ============================================================

local dap = require("dap")

require("dap-view").setup({
	auto_toggle = true
})

dap.adapters.gdb = {
  type = "executable",
  command = "gdb-multiarch",
  args = {
    "--interpreter=dap",
  },
}

dap.adapters.lldb = {
	type = "executable",
	command = "lldb-dap"
}

vim.keymap.set("n", "<leader>dc", dap.continue, {
    desc = "DAP continue",
})

vim.keymap.set("n", "<leader>dn", dap.step_over, {
    desc = "DAP step over",
})

vim.keymap.set("n", "<leader>di", dap.step_into, {
    desc = "DAP step into",
})

vim.keymap.set("n", "<leader>do", dap.step_out, {
    desc = "DAP step out",
})

vim.keymap.set("n", "<leader>dp", dap.pause, {
    desc = "DAP pause",
})

vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, {
    desc = "DAP toggle breakpoint",
})

vim.keymap.set("n", "<leader>dr", dap.repl.open, {
    desc = "DAP open REPL",
})

vim.keymap.set("n", "<leader>dt", dap.terminate, {
    desc = "DAP terminate",
})

-- ============================================================
-- NvimTree
-- ============================================================

require("nvim-tree").setup({
    view = {
        preserve_window_proportions = true,
    },
    actions = {
        open_file = {
            resize_window = true,
        },
    }
})

vim.keymap.set(
    "n",
    "<leader>e",
    "<cmd>NvimTreeToggle<CR>",
    { desc = "Toggle file tree" }
)

-- ============================================================
-- FzfLua
-- ============================================================

local fzf = require("fzf-lua")

fzf.setup({
	winopts = {
		on_create = function()
			vim.keymap.set("t", "<C-y>", "<CR>", {
				buffer = true,
				nowait = true,
				desc = "Accept picker selection",
			})
		end,
	},
})

fzf.register_ui_select()

vim.keymap.set(
    "n",
    "<leader>ff",
    fzf.files,
    { desc = "Find files" }
)

vim.keymap.set(
    "n",
    "<leader>fg",
    fzf.live_grep,
    { desc = "Search project" }
)

vim.keymap.set(
    "n",
    "<leader>fw",
    fzf.grep_cword,
    { desc = "Search word under cursor" }
)

vim.keymap.set(
    "n",
    "<leader>fb",
    fzf.buffers,
    { desc = "Buffers" }
)

vim.keymap.set(
    "n",
    "<leader>fh",
    fzf.helptags,
    { desc = "Help tags" }
)


-- ============================================================
-- CodeDiff
-- ============================================================

require("diffview").setup({
	preferred_adapter = "jj",
	enhanced_diff_hl = true,
	use_icons = true,

	view = {
		one_sided_layout = "raw",
		foldlevel = 99,

		default = { 
			layout = "diff2_horizontal",
			winbar_info = true
		},
		file_history = {
			layout = "diff2_horizontal",
			winbar_info = true,
		},
		merge_tool = {
			layout = "diff3_horizontal",
			winbar_info = true,
		},
  	},

	file_panel = {
		listing_style = "tree",
		win_config = { position = "left", width = 35 },
  	},

	hooks = {
		diff_buf_win_enter = function(_, winid)
			vim.wo[winid].foldenable = false
		end,
	},

  	keymaps = {},
})

-- ============================================================
-- gitsigns
-- ============================================================

require("gitsigns").setup({})

-- ============================================================
-- Smart Splits
-- ============================================================

local smart_splits = require("smart-splits")
local in_zellij = vim.env.ZELLIJ ~= nil

if in_zellij then
    require("smart-splits-backend-zellij-lua").setup({
        move_cursor = {
            pane_or_tab = false,
        },
    })
end

smart_splits.setup({
    move = {
        at_edge = "stop",
    },
    resize = {
        amount = 3,
    },
    mux = {
        backend = in_zellij and "smart-splits-backend-zellij-lua" or nil,
    },
})

-- Normal and terminal mode; preserve native insert-mode keys.
for key, direction in pairs({
    h = "left",
    j = "down",
    k = "up",
    l = "right",
}) do
    vim.keymap.set(
		"n",
        "<C-" .. key .. ">",
        smart_splits["move_cursor_" .. direction],
        { silent = true, desc = "Focus " .. direction .. " split" }
    )

    vim.keymap.set(
		"n",
        "<A-" .. key .. ">",
        smart_splits["resize_" .. direction],
        { silent = true, desc = "Resize " .. direction }
    )
end

-- ============================================================
-- OpenCode
-- ============================================================
--
require("render-markdown").setup({
    file_types = { "markdown", "opencode_output" },
    anti_conceal = {
        enabled = false,
    },
})

require("opencode").setup({
    preferred_picker = "fzf",
    preferred_completion = "blink",

    ui = {
        hide_single_tab = false,
    },

    hooks = {
        on_topbar_render = function(segments)
            local state = require("opencode.state")
            local session = state.active_session

            local directory
            if session then
                directory = (
                    session.location
                    and session.location.directory
                ) or session.directory
            end

            directory = directory
                or state.current_cwd
                or vim.fn.getcwd()

            local display = vim.fn.fnamemodify(directory, ":~")

            table.insert(segments, 1, {
                " " .. display .. " │ ",
                "OpencodeHint",
                align = "left",
            })

            return segments
        end,
    },
})
