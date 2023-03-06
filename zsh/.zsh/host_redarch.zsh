POWERLEVEL10K_DIR="/usr/share/zsh-theme-powerlevel10k"
ZSH_PLUGINS_DIR="/usr/share/zsh/plugins"

# fzf keybindings
source /usr/share/fzf/key-bindings.zsh

# arch specific aliases
alias ls='ls -lahp --color'
alias open=xdg-open

# funcs
function rh () {
  __jumpfunc "$HOME/redhat" $1
}

export GPG_TTY=$TTY
