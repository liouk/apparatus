export PATH="$PATH:$HOME/go/bin"

APPARATUS_WORKSPACE_ROOT="$HOME/liouk"
POWERLEVEL10K_DIR="/usr/share/zsh-theme-powerlevel10k"
ZSH_PLUGINS_DIR="/usr/share/zsh/plugins"

# fzf keybindings
[[ ! -r /usr/share/fzf/key-bindings.zsh ]] || source /usr/share/fzf/key-bindings.zsh

# Arch-specific aliases
alias ls='ls -lahp --color'
alias open=xdg-open
alias vlc='QT_QPA_PLATFORM=wayland vlc'
alias zed=zeditor
alias z=zeditor
alias zap='zeditor "$HOME/.apparatus"'

export GPG_TTY="$TTY"
