# Keep future manual Go installs alongside the platform-installed tools.
export GOBIN="$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"

APPARATUS_WORKSPACE_ROOT="$HOME/liouk"
POWERLEVEL10K_DIR="$HOME/.local/share/powerlevel10k"
ZSH_PLUGINS_DIR="/usr/share"

# Fedora packages fzf's shell integration in a different directory from Arch.
[[ ! -r /usr/share/fzf/shell/key-bindings.zsh ]] || source /usr/share/fzf/shell/key-bindings.zsh

alias ls='ls -lahp --color'
alias vlc='QT_QPA_PLATFORM=wayland vlc'
alias zed=zeditor
alias z=zeditor
alias zap='zeditor "$HOME/liouk/apparatus"'

export GPG_TTY="$TTY"
