# Visual
PS1='%1~ %# '

# Basic
setopt NO_MENU_COMPLETE
autoload -Uz compinit
compinit

# Aliases
alias cd='z'
alias cdi='zi'
alias vim='nvim'
alias v='nvim'
alias lg='lazygit'
alias python3='python'
alias ca='conda activate'
alias cde='conda deactivate'
alias co='cursor'
alias py='python'
alias dh='du -sh * | sort -h'
alias cof='co "$(fzf)"'
alias vin='nvim --cmd "autocmd VimEnter * ++once lua vim.schedule(function() vim.cmd([[enew | startinsert]]) end)"'

# Config commands
alias zshc='vim ~/.zshrc'
alias vimc='vim ~/.config/nvim/init.lua'

source /usr/local/opt/fzf/shell/key-bindings.zsh
source ~/.config/zsh/functions.zsh
source ~/code/sc/shell/fzfcode/fzfcode.sh

export EDITOR=nvim
set -o vi
zle -N vi-yank-pbcopy
bindkey -M vicmd 'y' vi-yank-pbcopy

export HOMEBREW_AUTO_UPDATE_SECS=604800 # 1 week

export PATH="$(brew --prefix)/bin:$PATH"

# Env
export JOPLIN_TOKEN='5940ad1a9ac11a2ded79d470c596ad7f6bed5f75202e357b39dbb018d2c1dc6b4be04fef2d4badb561b1cd0f404792a692af7f6c9c53396cf66d0746702b590b'

# Plugins
eval "$(zoxide init zsh)"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$("$HOME/mambaforge/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOME/mambaforge/etc/profile.d/conda.sh" ]; then
        . "$HOME/mambaforge/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/mambaforge/bin:$PATH"
    fi
fi
unset __conda_setup

if [ -f "$HOME/mambaforge/etc/profile.d/mamba.sh" ]; then
    . "$HOME/mambaforge/etc/profile.d/mamba.sh"
fi
# <<< conda initialize <<<

# Conda alias hacks
conda(){ mamba "$@"; }
cconda(){ command conda "$@"; }

# Source cursor specific file and return if cursor
if [[ -n "$CURSOR_AGENT" ]]; then
  source ~/.config/zsh/.zshrc_cursor
  return
fi

# Auto launch tmux
if command -v tmux >/dev/null 2>&1; then
  if [ -z "$TMUX" ] && [ "$TERM_PROGRAM" != "vscode" ] && [ "$TERM_PROGRAM" != "cursor" ]; then
    tmux attach -t default || tmux new -s default
  fi
fi
export PATH="/usr/local/bin:$PATH"
