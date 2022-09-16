# Configure zsh prompt
source ~/.zsh/.zsh_prompt
precmd() { eval "$PROMPT_COMMAND" }

export VISUAL="nvim"
export EDITOR="nvim"

# Aliases
source ~/.zsh/.zsh_aliases

# Futurae
export PATH="$GOPATH/bin:$PATH"
export FUTURAE="/Users/ilias/Workspace/futurae"

[[ -s "/Users/ilias/.gvm/scripts/gvm" ]] && source "/Users/ilias/.gvm/scripts/gvm"

# Misc
export LC_ALL=en_US.UTF-8
KEYTIMEOUT=1
bindkey -e

# Load Git completion
zstyle ':completion:*:*:git:*' script ~/.zsh/git-completion.bash
fpath=(~/.zsh $fpath)

autoload -Uz compinit && compinit

# brew
eval $(/opt/homebrew/bin/brew shellenv)
export PATH="/opt/homebrew/bin:$PATH"

# rbenv
export PATH="$HOME/.rbenv/bin:/usr/local/sbin:$PATH"
eval "$(rbenv init -)"

# direnv
eval "$(direnv hook zsh)"

# GNU make
export PATH="/usr/local/opt/make/libexec/gnubin:$PATH"

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='find .'

# convenience function to jump between futurae repos
function fu () {
  local futurae_dir="$HOME/Workspace/futurae"
  case $1 in
    "ls"|"-l"|"--ls")
      ls -lah $futurae_dir
      ;;
    *)
      cd "$futurae_dir/$1"
      ;;
  esac
}

bindkey \^U backward-kill-line

fortune -s

# blackbox convenience func
function bbox () {
  local rootdir="keyrings"
  local keyring="$rootdir/$1"

  case $1 in
    "")
      echo "using keyring: $BLACKBOXDATA"
      if command -v gum &> /dev/null
      then
        keyring=$(/bin/ls -1 $rootdir | gum choose)
        keyring="$rootdir/$keyring"
      else
        return
      fi
      ;;
    "-l"|"--list")
      echo "available keyrings:"
      /bin/ls -1 $rootdir
      return
      ;;
  esac

  [ -d "$keyring" ] || { echo "unknown keyring: $keyring"; return 1; }
  export BLACKBOXDATA="$keyring"
  echo "now using keyring: $keyring"
}
