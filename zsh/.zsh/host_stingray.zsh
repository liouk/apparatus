POWERLEVEL10K_DIR="/usr/local/opt/powerlevel10k"
ZSH_PLUGINS_DIR="/usr/local/share"

# brew
BREW_PATH=/usr/local/Homebrew
if [[ $(uname -m) == 'arm64' ]]; then
  BREW_PATH=/opt/homebrew
fi
eval $($BREW_PATH/bin/brew shellenv)
export PATH="BREW_PATH/bin:$PATH"

# fzf
if [[ ! "$PATH" == */usr/local/opt/fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/usr/local/opt/fzf/bin"
fi
source "/usr/local/opt/fzf/shell/key-bindings.zsh"

# gpg
export GPG_TTY=$(tty)

# keybindings
bindkey \^U backward-kill-line

# macos specific aliases
alias ls='ls -Glahp'
alias nas='test -d /Volumes/ilias || . ~/.apparatus/util/macmount.sh; cd /Volumes/ilias'
command -v gxargs 2>&1 >/dev/null && { alias xargs='gxargs' }

# funcs
function gl () {
  __jumpfunc "$HOME/Workspace/github.com/liouk" $1
}
