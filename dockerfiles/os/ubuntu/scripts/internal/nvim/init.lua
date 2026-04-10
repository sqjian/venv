-------------------------------------------------------------------------------
-- 维护者:
--       sqjian - shengqi.jian@qq.com
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- 基础选项
-------------------------------------------------------------------------------
local opt = vim.opt

opt.shortmess:append("I")
opt.fileencoding = "utf-8"
opt.fileencodings = { "ucs-bom", "utf-8", "gbk", "gb18030", "big5", "euc-jp", "latin1" }

-- 现代默认设置
opt.termguicolors = true
opt.number = true
opt.relativenumber = false
opt.signcolumn = "yes"
opt.cursorline = false
opt.updatetime = 250
opt.timeoutlen = 300
opt.ttimeoutlen = 10

-- 鼠标支持
opt.mouse = "a"

-- 滚动边距
opt.scrolloff = 8
opt.sidescrolloff = 8

-- 搜索
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true

-- 编辑
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.smartindent = true
opt.undofile = true

-- 禁用备份和交换文件
opt.backup = false
opt.writebackup = false
opt.swapfile = false

-- 补全
opt.completeopt = { "menu", "menuone", "noselect" }

-- 命令行补全
opt.wildmode = "longest:full,full"
opt.wildignorecase = true

-- 分割窗口
opt.splitright = true
opt.splitbelow = true

-- 折叠
opt.foldmethod = "indent"
opt.foldlevelstart = 99

-- 系统剪贴板
opt.clipboard = "unnamedplus"

-------------------------------------------------------------------------------
-- 键位映射
-------------------------------------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local keymap = vim.keymap.set

-- 清除搜索高亮
keymap("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- 更好的窗口导航
keymap("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- 更好的缩进
keymap("v", "<", "<gv", { desc = "Indent left" })
keymap("v", ">", ">gv", { desc = "Indent right" })

-- 移动行
keymap("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
keymap("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
keymap("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
keymap("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

-- 保存/退出
keymap("n", "<leader>w", "<cmd>w<cr>", { desc = "Save" })
keymap("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })

-- 缓冲区导航
keymap("n", "<S-h>", "<cmd>bprev<cr>", { desc = "Prev buffer" })
keymap("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
keymap("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })

-- 终端模式退出
keymap("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- quickfix 导航
keymap("n", "]q", function()
  local ok, err = pcall(vim.cmd.cnext)
  if not ok then
    if type(err) == "string" and (err:match("E553") or err:match("E42")) then
      return
    end
    error(err)
  end
end, { desc = "Next quickfix" })
keymap("n", "[q", function()
  local ok, err = pcall(vim.cmd.cprev)
  if not ok then
    if type(err) == "string" and (err:match("E553") or err:match("E42")) then
      return
    end
    error(err)
  end
end, { desc = "Prev quickfix" })

-- 诊断导航
keymap("n", "]d", function()
  vim.diagnostic.jump({ count = 1 })
end, { desc = "Next diagnostic" })
keymap("n", "[d", function()
  vim.diagnostic.jump({ count = -1 })
end, { desc = "Prev diagnostic" })
keymap("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show diagnostic" })

-------------------------------------------------------------------------------
-- 内置文件浏览器 (netrw)
-------------------------------------------------------------------------------
vim.g.netrw_banner = 0        -- 隐藏横幅
vim.g.netrw_liststyle = 3     -- 树形视图
vim.g.netrw_winsize = 25      -- 窗口宽度 25%

keymap("n", "<leader>e", "<cmd>Explore<cr>", { desc = "File explorer" })

-------------------------------------------------------------------------------
-- 状态栏
-------------------------------------------------------------------------------
local mode_map = {
  ["n"]     = "NORMAL",
  ["no"]    = "OP-PENDING",
  ["nov"]   = "OP-PENDING",
  ["noV"]   = "OP-PENDING",
  ["no\22"] = "OP-PENDING",
  ["niI"]   = "NORMAL",
  ["niR"]   = "NORMAL",
  ["niV"]   = "NORMAL",
  ["nt"]    = "NORMAL",
  ["ntT"]   = "NORMAL",
  ["v"]     = "VISUAL",
  ["vs"]    = "VISUAL",
  ["V"]     = "V-LINE",
  ["Vs"]    = "V-LINE",
  ["\22"]   = "V-BLOCK",
  ["\22s"]  = "V-BLOCK",
  ["s"]     = "SELECT",
  ["S"]     = "S-LINE",
  ["\19"]   = "S-BLOCK",
  ["i"]     = "INSERT",
  ["ic"]    = "INSERT",
  ["ix"]    = "INSERT",
  ["R"]     = "REPLACE",
  ["Rc"]    = "REPLACE",
  ["Rx"]    = "REPLACE",
  ["Rv"]    = "V-REPLACE",
  ["Rvc"]   = "V-REPLACE",
  ["Rvx"]   = "V-REPLACE",
  ["c"]     = "COMMAND",
  ["cv"]    = "VIM EX",
  ["ce"]    = "EX",
  ["r"]     = "PROMPT",
  ["rm"]    = "MORE",
  ["r?"]    = "CONFIRM",
  ["!"]     = "SHELL",
  ["t"]     = "TERMINAL",
}

local function get_mode()
  return mode_map[vim.api.nvim_get_mode().mode] or "UNKNOWN"
end

function _G.statusline()
  local parts = {
    " %n ",                                     -- 缓冲区编号
    "%1* %<%F%m%r%h%w ",                        -- 文件路径、修改标记、只读标记
    "%3*│",                                     -- 分隔符
    "%2* %Y ",                                  -- 文件类型
    "%3*│",                                     -- 分隔符
    "%2* %{&fenc!=#''?&fenc:&enc}",             -- 编码
    " (%{&ff}) ",                               -- 文件格式
    "%=",                                       -- 右侧
    "%2* Col: %02v ",                           -- 列号
    "%3*│",                                     -- 分隔符
    "%1* Ln: %02l/%L (%3p%%) ",                 -- 行号/总行数
    "%0* " .. get_mode() .. " ",                -- 当前模式
  }
  return table.concat(parts)
end

-- 状态栏高亮组
local function setup_statusline_highlights()
  vim.api.nvim_set_hl(0, "StatusLine", { fg = "#000000", bg = "#8fbfdc", bold = true })
  vim.api.nvim_set_hl(0, "User1", { fg = "#adadad", bg = "#4e4e4e" })
  vim.api.nvim_set_hl(0, "User2", { fg = "#adadad", bg = "#303030" })
  vim.api.nvim_set_hl(0, "User3", { fg = "#303030", bg = "#303030" })
end

setup_statusline_highlights()

-- 切换颜色主题后重新设置状态栏高亮
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("StatuslineColors", { clear = true }),
  callback = setup_statusline_highlights,
})

opt.laststatus = 2
opt.showmode = false
opt.statusline = "%!v:lua.statusline()"

-- 模式切换时强制刷新状态栏
vim.api.nvim_create_autocmd("ModeChanged", {
  group = vim.api.nvim_create_augroup("StatuslineMode", { clear = true }),
  callback = function()
    vim.cmd.redrawstatus()
  end,
})

-------------------------------------------------------------------------------
-- 大文件优化 (>5MB)
-------------------------------------------------------------------------------
local big_file_threshold = 5 * 1024 * 1024 -- 5MB

local function is_big_file(buf)
  local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
  return ok and stats and stats.size > big_file_threshold
end

vim.api.nvim_create_autocmd("BufReadPre", {
  group = vim.api.nvim_create_augroup("BigFile", { clear = true }),
  callback = function(args)
    if not is_big_file(args.buf) then return end

    vim.b[args.buf].big_file = true

    -- 禁用耗性能的选项
    local buf_opts = {
      swapfile = false,
      undofile = false,
    }
    for k, v in pairs(buf_opts) do
      vim.bo[args.buf][k] = v
    end

    vim.api.nvim_create_autocmd("BufWinEnter", {
      buffer = args.buf,
      callback = function()
        -- 禁用当前缓冲区的语法高亮 (非全局)
        vim.bo[args.buf].syntax = ""
        pcall(vim.treesitter.stop, args.buf)

        local win_opts = {
          number = false,
          relativenumber = false,
          signcolumn = "no",
          foldmethod = "manual",
          foldenable = false,
          cursorline = false,
          cursorcolumn = false,
          list = false,
          spell = false,
          wrap = false,
        }
        for k, v in pairs(win_opts) do
          vim.wo[0][k] = v
        end

        -- 每个缓冲区只通知一次
        if not vim.b[args.buf].big_file_notified then
          vim.b[args.buf].big_file_notified = true
          vim.notify("Big file mode: some features disabled for performance", vim.log.levels.WARN)
        end
      end,
    })
  end,
})

-------------------------------------------------------------------------------
-- 自动命令
-------------------------------------------------------------------------------
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- 复制时高亮
autocmd("TextYankPost", {
  group = augroup("YankHighlight", { clear = true }),
  callback = function()
    vim.hl.on_yank({ timeout = 200 })
  end,
})

-- 插入模式高亮当前行 (大文件跳过)
local insert_hl_group = augroup("InsertHighlight", { clear = true })
autocmd("InsertEnter", {
  group = insert_hl_group,
  callback = function()
    if vim.b.big_file then return end
    vim.wo.cursorline = true
    vim.api.nvim_set_hl(0, "StatusLine", { fg = "#000000", bg = "#d7afff", bold = true })
  end,
})
autocmd("InsertLeave", {
  group = insert_hl_group,
  callback = function()
    if vim.b.big_file then return end
    vim.wo.cursorline = false
    vim.api.nvim_set_hl(0, "StatusLine", { fg = "#000000", bg = "#8fbfdc", bold = true })
  end,
})

-- 恢复光标位置 (排除 git 提交等特殊文件)
autocmd("BufReadPost", {
  group = augroup("RestoreCursor", { clear = true }),
  callback = function(args)
    -- 延迟执行，等待 filetype 检测完成
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(args.buf) then return end
      local exclude_ft = { "gitcommit", "gitrebase", "help" }
      if vim.tbl_contains(exclude_ft, vim.bo[args.buf].filetype) then return end
      local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
      local line_count = vim.api.nvim_buf_line_count(args.buf)
      if mark[1] > 0 and mark[1] <= line_count then
        -- 在缓冲区上下文中执行，确保操作正确的窗口
        vim.api.nvim_buf_call(args.buf, function()
          pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end)
      end
    end)
  end,
})

-- 检测文件外部修改
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("CheckFile", { clear = true }),
  callback = function()
    if vim.bo.buftype == "" then
      vim.cmd.checktime()
    end
  end,
})

-- 窗口大小改变时自动调整分割
autocmd("VimResized", {
  group = augroup("ResizeSplits", { clear = true }),
  callback = function()
    vim.cmd.tabdo("wincmd =")
  end,
})

-- 保存时自动删除行尾空格 (排除 markdown 和大文件)
autocmd("BufWritePre", {
  group = augroup("TrimWhitespace", { clear = true }),
  pattern = "*",
  callback = function()
    if vim.bo.buftype ~= "" then return end
    if vim.bo.filetype == "markdown" then return end
    if vim.b.big_file then return end
    local view = vim.fn.winsaveview()
    vim.cmd([[keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(view)
  end,
})

-- 特定文件类型缩进
autocmd("FileType", {
  group = augroup("FileTypeIndent", { clear = true }),
  pattern = { "lua", "yaml", "json", "html", "css", "javascript", "typescript" },
  callback = function()
    vim.bo.shiftwidth = 2
    vim.bo.tabstop = 2
  end,
})

-------------------------------------------------------------------------------
-- 终端兼容处理 (neovim/neovim#38651)
-- xterm.js 等终端中 Shift+数字键在 Kitty 协议下失效
-------------------------------------------------------------------------------
local function needs_shift_number_fix()
  -- VSCode 终端
  if vim.env.TERM_PROGRAM == "vscode" then return true end
  -- docker exec 环境（检测容器内运行）
  if vim.uv.fs_stat("/.dockerenv") then return true end
  -- 用户可通过环境变量强制启用
  if vim.env.NVIM_SHIFT_NUMBER_FIX == "1" then return true end
  return false
end

if needs_shift_number_fix() then
  local shift_maps = {
    ["<S-1>"] = "!", ["<S-2>"] = "@", ["<S-3>"] = "#", ["<S-4>"] = "$",
    ["<S-5>"] = "%", ["<S-6>"] = "^", ["<S-7>"] = "&", ["<S-8>"] = "*",
    ["<S-9>"] = "(", ["<S-0>"] = ")",
  }
  for from, to in pairs(shift_maps) do
    vim.keymap.set({ "n", "x", "s", "o", "i", "c", "t" }, from, to, { noremap = true })
  end
end

-------------------------------------------------------------------------------
-- 诊断配置 (内置)
-------------------------------------------------------------------------------
vim.diagnostic.config({
  virtual_text = { spacing = 4, prefix = "●" },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = true,
  },
})
