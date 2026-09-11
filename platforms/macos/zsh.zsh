if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

APPARATUS_WORKSPACE_ROOT="$HOME/Workspace/github.com/liouk"
export PATH="$HOME/.local/bin:$PATH"

if command -v brew > /dev/null; then
  HOMEBREW_PREFIX="$(brew --prefix)"
  # Use FIDO2-capable OpenSSH for authentication and Git's SSH signatures.
  export PATH="$HOMEBREW_PREFIX/opt/openssh/bin:$PATH"
  POWERLEVEL10K_DIR="$HOMEBREW_PREFIX/share/powerlevel10k"
  ZSH_PLUGINS_DIR="$HOMEBREW_PREFIX/share"
fi

if command -v fzf > /dev/null; then
  source <(fzf --zsh)
fi

# macOS-specific aliases
alias ls='ls -Glahp'
alias zap='cd "$HOME/workspace/apparatus"'

export GPG_TTY="$TTY"
