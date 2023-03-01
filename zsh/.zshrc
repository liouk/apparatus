# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Aliases
source ~/.zsh/.zsh_aliases

# helper funcs
source ~/.zsh/.zsh_funcs

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

# Default editor
export VISUAL="vim"
export EDITOR="vim"
if type "nvim" > /dev/null; then
  export VISUAL="nvim"
  export EDITOR="nvim"
  alias vim='nvim'

  # bring vim to foreground with Ctrl-z if suspended
  function fg-nvim() { fg %nvim }
  zle -N fg-nvim
  bindkey '^Z' fg-nvim
fi

# Misc
export LC_ALL=en_US.UTF-8
KEYTIMEOUT=1
bindkey -e

# Load Git completion
zstyle ':completion:*:*:git:*' script ~/.zsh/git-completion.bash
fpath=(~/.zsh $fpath)
autoload -Uz compinit && compinit

# direnv
if type "direnv" > /dev/null; then
  eval "$(direnv hook zsh)"
fi

# fzf
export FZF_DEFAULT_COMMAND='find .'
export FZF_CTRL_T_COMMAND='find .'

# navi (widget used with ctrl+G)
if type "navi" > /dev/null; then
  eval "$(navi widget zsh)"
fi

# Platform specific
if [[ "$OSTYPE" == "darwin"* ]]; then
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

elif grep -q "ID=fedora" "/etc/os-release" 2>/dev/null; then
  POWERLEVEL10K_DIR="/opt/powerlevel10k"
  ZSH_PLUGINS_DIR="/usr/share"

  # fzf keybindings
  source /usr/share/fzf/shell/key-bindings.zsh

  # fedora specific aliases
  alias ls='ls -lahp --color'

elif [ -f "/etc/arch-release" ]; then
  POWERLEVEL10K_DIR="/usr/share/zsh-theme-powerlevel10k"
  ZSH_PLUGINS_DIR="/usr/share/zsh/plugins"

  # fzf keybindings
  source /usr/share/fzf/key-bindings.zsh

  # arch specific aliases
  alias ls='ls -lahp --color'
fi

# plugins

# zsh syntax highlighting and autosuggestions
source "${ZSH_PLUGINS_DIR}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "${ZSH_PLUGINS_DIR}/zsh-autosuggestions/zsh-autosuggestions.zsh"

# powerlevel10k
source "${POWERLEVEL10K_DIR}/powerlevel10k.zsh-theme"
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# additional config files that live outside apparatus
for conf in $(find -L "$HOME/.zsh/conf.d" -type f); do
  source $conf
done
