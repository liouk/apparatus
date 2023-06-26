PATH=$PATH:~/go/bin

POWERLEVEL10K_DIR="/usr/share/zsh-theme-powerlevel10k"
ZSH_PLUGINS_DIR="/usr/share/zsh/plugins"

# fzf keybindings
source /usr/share/fzf/key-bindings.zsh

# arch specific aliases
alias ls='ls -lahp --color'
alias open=xdg-open
alias vlc='QT_QPA_PLATFORM=wayland vlc'

# oc completion
if command -v oc &> /dev/null; then
  autoload -Uz compinit && compinit
  source <(oc completion zsh)
fi

# funcs
function lk () {
  __jumpfunc "$HOME/liouk" $1
}

function rh () {
  __jumpfunc "$HOME/redhat" $1
}

function occ () {
  xdg-open $(oc whoami --show-console)
}

export GPG_TTY=$TTY
