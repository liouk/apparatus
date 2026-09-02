if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

APPARATUS_WORKSPACE_ROOT="$HOME/Workspace/github.com/liouk"

if command -v brew > /dev/null; then
  HOMEBREW_PREFIX="$(brew --prefix)"
  POWERLEVEL10K_DIR="$HOMEBREW_PREFIX/share/powerlevel10k"
  ZSH_PLUGINS_DIR="$HOMEBREW_PREFIX/share"
fi

if command -v fzf > /dev/null; then
  source <(fzf --zsh)
fi

# macOS-specific aliases
alias ls='ls -Glahp'
alias z=zed
alias zap='zed "$HOME/Workspace/github.com/liouk/apparatus"'

command -v gxargs > /dev/null && alias xargs=gxargs
export GPG_TTY="$TTY"
