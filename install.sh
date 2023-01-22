#!/usr/bin/env bash

set -e
set -o pipefail

function install_macos {

  # install brew
  which -s brew &>/dev/null || { /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; }

  # install brew packages
  brew install \
    findutils \
    git \
    tig \
    neovim \
    node \ # required to get npm and install some neovim LSPs
    stow \
    fzf \
    ripgrep \
    direnv \
    bat \
    jq \
    navi \
    romkatv/powerlevel10k/powerlevel10k \
    zsh-syntax-highlighting \
    zsh-autosuggestions \
    btop \
    gnupg pinentry-mac \
    itchyny/tap/mmv \
    saulpw/vd/visidata

  # fonts
  brew tap homebrew/cask-fonts
  brew install --cask font-jetbrains-mono-nerd-font

  # fzf key bindings
  $(brew --prefix)/opt/fzf/install --key-bindings --no-completion --no-bash --no-fish --no-update-rc

  # kitty
  curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n
}

function stow_macos {
  stow --restow --target="$HOME" zsh
  stow --restow --target="$HOME" git
  stow --restow --target="$HOME" tig
  stow --restow --target="$HOME" powerlevel10k
  stow --restow --target="$HOME/.config" kitty
  stow --restow --target="$HOME/.config" karabiner
  stow --restow --target="$HOME/.config" nvim
  stow --restow --target="$HOME/Google Drive/My Drive/Notes" obsidian

  mkdir -p "$HOME/Library/Application Support/navi"
  stow --restow --target="$HOME/Library/Application Support/navi" navi
}

function unstow_macos {
  stow --delete --target="$HOME" zsh
  stow --delete --target="$HOME" git
  stow --delete --target="$HOME" tig
  stow --delete --target="$HOME" powerlevel10k
  stow --delete --target="$HOME/.config" kitty
  stow --delete --target="$HOME/.config" karabiner
  stow --delete --target="$HOME/.config" nvim
  stow --delete --target="$HOME/Library/Application Support/navi" navi
  stow --delete --target="$HOME/Google Drive/Notes" obsidian
}

function apparatus {
  local installdir="$1"
  local link="$2"

  if [ -d "${installdir}" ]; then
    echo "will not clone apparatus; it already exists in $installdir"
    return
  fi

  git clone git@github.com:liouk/apparatus.git "$installdir"
  [ -e "$link" ] || { ln -s "$installdir" "$link"; }
}

function detect_os {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    DETECTED_OS="macos"
    return
  fi

  if [[ -f "/etc/os-release" ]]; then
    source "/etc/os-release"
    if [[ "$ID" == "fedora" ]] && [[ "$PRETTY_NAME" == *Fedora*Server* ]]; then
      DETECTED_OS="fedora-server"
      return
    fi
  fi
}

function parse_opts {
  while :
  do
    case "$1" in
      --check-support)
        CHECK_SUPPORT=1
        shift
        ;;
      "")
        # no (more) options found
        break
        ;;
      *)
        echo "unexpected option: $1"
        exit 1
        ;;
    esac
  done
}

function main {

  detect_os
  parse_opts "$@"

  if [ -n "$CHECK_SUPPORT" ]; then
    if [[ "$DETECTED_OS" == "" ]]; then
      echo "unsupported operating system (supported: macos, fedora-server)"
      exit 1
    fi

    echo "operating system supported ($DETECTED_OS)"
    exit 0
  fi

  case $DETECTED_OS in

    macos)
      install_macos "$@"
      apparatus "$HOME/Workspace/personal/apparatus" "$HOME/.apparatus"
      stow_macos "$@"
      ;;

    fedora-server)
      ;;

    *)
      echo "unsupported operating system (supported: macos, fedora-server)"
      exit 1
      ;;
  esac
}

main "$@"
