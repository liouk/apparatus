# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt INC_APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY

# Editor
export VISUAL="nvim"
export EDITOR="nvim"

# Misc
export LC_ALL=en_US.UTF-8
KEYTIMEOUT=1
bindkey -e

# Load Git completion
zstyle ':completion:*:*:git:*' script ~/.zsh/git-completion.bash
fpath=(~/.zsh $fpath)

autoload -Uz compinit && compinit

# brew
BREW_PATH=/usr/local/Homebrew
if [[ $(uname -m) == 'arm64' ]]; then
  BREW_PATH=/opt/homebrew
fi
eval $($BREW_PATH/bin/brew shellenv)
export PATH="BREW_PATH/bin:$PATH"

# direnv
eval "$(direnv hook zsh)"

# GNU make
export PATH="/usr/local/opt/make/libexec/gnubin:$PATH"

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='find .'
export FZF_CTRL_T_COMMAND='find .'

# navi (widget used with ctrl+G)
eval "$(navi widget zsh)"

# gpg
export GPG_TTY=$(tty)

# keybindings
bindkey \^U backward-kill-line

# bring vim to foreground with Ctrl-z if suspended
function fg-nvim() {
  fg %nvim
}
zle -N fg-nvim
bindkey '^Z' fg-nvim

# Aliases
source ~/.zsh/.zsh_aliases

# helper funcs
source ~/.zsh/.zsh_funcs

# zsh syntax highlighting and autosuggestions
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# powerlevel10k
source /usr/local/opt/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
