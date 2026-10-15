# Debian packages the shared Zsh plugins below /usr/share.
ZSH_PLUGINS_DIR="/usr/share"
POWERLEVEL10K_DIR="$HOME/.local/share/powerlevel10k"
export PATH="$HOME/.local/bin:$PATH"

alias ls='ls -lahp --color=auto'
alias fd='fdfind'

# Enable fzf's Zsh widgets, including Ctrl-R reverse history search.
if command -v fzf > /dev/null; then
  source <(fzf --zsh)
fi
