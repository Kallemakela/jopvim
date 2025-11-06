local runner = require("coderunner.runner")

-- Custom strategy: reuse Runner window, send command to existing terminal
vim.g["test#custom_strategies"] = {
  use_runner = function(cmd)
    runner.use_runner_window("vim-test", cmd)
  end,
}

vim.g["test#python#runner"] = "pytest"
vim.g["test#python#pytest#options"] = "-q -s"
vim.g["test#strategy"] = "use_runner"