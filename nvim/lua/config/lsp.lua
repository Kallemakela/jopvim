local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()
require("mason-lspconfig").setup({
  ensure_installed = { "lua_ls", "pyright", "ts_ls", "jsonls", "bashls" },
  handlers = {
    -- default for all servers
    function(server_name)
      lspconfig[server_name].setup({ capabilities = capabilities })
    end,

    -- lua
    ["lua_ls"] = function()
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
          },
        },
      })
    end,

    -- python
    ["pyright"] = function()
      lspconfig.pyright.setup({
        capabilities = capabilities,
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "basic",
              autoImportCompletions = true,
              diagnosticMode = "workspace",
            },
          },
        },
      })
    end,

    -- typescript/javascript (handle old/new server ids)
    ["ts_ls"] = function()
      (lspconfig.ts_ls or lspconfig.tsserver).setup({
        capabilities = capabilities,
      })
    end,

    -- json
    ["jsonls"] = function()
      lspconfig.jsonls.setup({ capabilities = capabilities })
    end,

    -- bash
    ["bashls"] = function()
      lspconfig.bashls.setup({ capabilities = capabilities })
    end,
  },
})

