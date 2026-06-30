-- ============================================
-- 语法高亮引擎：nvim-treesitter
-- Treesitter 比传统正则高亮更精确，
-- 能理解代码结构，支持语义级高亮
-- ============================================

return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate", -- 安装后自动更新解析器
  lazy = false, -- 新版 nvim-treesitter 不支持 lazy-loading
  cmd = { "TSInstall", "TSUpdate", "TSConfigInfo" },

  opts = {
    install_dir = vim.fn.stdpath("data") .. "/site",

    -- 确保安装的解析器（对应你常用的语言）
    ensure_installed = {
      "bash",
      "c",
      "cpp",
      "css",
      "diff",
      "go",
      "html",
      "java",
      "json",
      "lua",
      "markdown",
      "markdown_inline",
      "query",
      "regex",
      "rust",
      "vim",
      "vimdoc",
      "yaml",
    },

    highlight_filetypes = {
      "bash",
      "c",
      "cpp",
      "css",
      "go",
      "html",
      "java",
      "javascript",
      "json",
      "jsonc",
      "lua",
      "markdown",
      "markdown.mdx",
      "rust",
      "sh",
      "vim",
      "yaml",
      "yaml.docker-compose",
      "yaml.gitlab",
      "yaml.helm-values",
    },

    indent_filetypes = {
      c = true,
      cpp = true,
      go = true,
      java = true,
      lua = true,
      rust = true,
      vim = true,
    },
  },

  config = function(_, opts)
    local ts = require("nvim-treesitter")

    ts.setup({ install_dir = opts.install_dir })

    local ok_installed, installed = pcall(ts.get_installed, "parsers")
    if ok_installed then
      local seen = {}
      for _, lang in ipairs(installed) do
        seen[lang] = true
      end

      local missing = {}
      for _, lang in ipairs(opts.ensure_installed or {}) do
        if not seen[lang] then
          table.insert(missing, lang)
        end
      end

      if #missing > 0 then
        if vim.fn.executable("tree-sitter") == 1 then
          ts.install(missing)
        else
          vim.notify(
            "Treesitter 解析器缺失，且未找到 tree-sitter CLI；请先安装 tree-sitter-cli",
            vim.log.levels.WARN
          )
        end
      end
    end

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
      pattern = opts.highlight_filetypes,
      callback = function(args)
        local ok = pcall(vim.treesitter.start, args.buf)
        if ok and opts.indent_filetypes[vim.bo[args.buf].filetype] then
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
