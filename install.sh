#!/usr/bin/env bash

set -e
set -o pipefail
[ -n "$TRACE" ] && { set -x; }

function install_macos {

  # install brew
  which -s brew &>/dev/null || { /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; }

  # install brew packages
  brew install \
    findutils \
    git \
    tig \
    neovim \
    node \
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

  # kitty
  curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n
}

function stow_macos {
  local apparatus_dir="$1"
  pushd . > /dev/null
  cd $apparatus_dir
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
  popd > /dev/null
}

function unstow_macos {
  local apparatus_dir="$1"
  pushd . > /dev/null
  cd $apparatus_dir
  stow --delete --target="$HOME" zsh
  stow --delete --target="$HOME" git
  stow --delete --target="$HOME" tig
  stow --delete --target="$HOME" powerlevel10k
  stow --delete --target="$HOME/.config" kitty
  stow --delete --target="$HOME/.config" karabiner
  stow --delete --target="$HOME/.config" nvim
  stow --delete --target="$HOME/Library/Application Support/navi" navi
  stow --delete --target="$HOME/Google Drive/Notes" obsidian
  popd > /dev/null
}

function install_fedora_server {
  sudo dnf install -y \
    zsh \
    zsh-syntax-highlighting \
    zsh-autosuggestions \
    git \
    tig \
    stow \
    fzf \
    ripgrep \
    btop

  # change to zsh as default shell
  chsh -s $(which zsh)

  # powerlevel10k
  sudo git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /opt/powerlevel10k
}

function stow_fedora_server {
  local apparatus_dir="$1"
  pushd . > /dev/null
  cd $apparatus_dir
  stow --restow --target="$HOME" zsh
  stow --restow --target="$HOME" git
  stow --restow --target="$HOME" tig
  stow --restow --target="$HOME" powerlevel10k
  popd > /dev/null
}

function unstow_fedora_server {
  local apparatus_dir="$1"
  pushd . > /dev/null
  stow --delete --target="$HOME" zsh
  stow --delete --target="$HOME" git
  stow --delete --target="$HOME" tig
  stow --delete --target="$HOME" powerlevel10k
  cd $apparatus_dir
  popd > /dev/null
}

function apparatus {
  local installdir="$1"
  local link="$2"

  if [ -d "${installdir}" ]; then
    echo "will not clone apparatus; it already exists in $installdir"
    return
  fi

  git clone git@github.com:liouk/apparatus.git "$installdir"
  if [ -n "$link" ]; then
    [ -e "$link" ] || { ln -s "$installdir" "$link"; }
  fi
}

function detect_os {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    DETECTED_OS="macos"
    return
  fi

  if grep -q "PRETTY_NAME=.*Fedora.*Server.*" "/etc/os-release" 2>/dev/null; then
    DETECTED_OS="fedora-server"
    return
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

  case "$DETECTED_OS" in

    macos)
      install_macos
      apparatus "$HOME/Workspace/personal/apparatus" "$HOME/.apparatus"
      stow_macos "$HOME/Workspace/personal/apparatus"
      ;;

    fedora-server)
      install_fedora_server
      apparatus "$HOME/.apparatus"
      stow_fedora_server "$HOME/.apparatus"
      ;;

    *)
      echo "unsupported operating system (supported: macos, fedora-server)"
      exit 1
      ;;

  esac
}

main "$@"
