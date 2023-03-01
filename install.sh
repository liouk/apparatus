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
    coreutils \
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
  stow --delete --target="$HOME/Google Drive/My Drive/Notes" obsidian
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

  # powerlevel10k
  local p10k_dir="/opt/powerlevel10k"
  if [ -d "$p10k_dir" ]; then
    echo "will not clone powerlevel10k; it already exists in $p10k_dir"
  else
    sudo git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /opt/powerlevel10k
  fi
}

function wrapup_linux {
  echo -e "\nSetup complete! Change your shell to zsh by running:\n\tchsh -s \$(which zsh)"
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

function install_arch {
  sudo pacman -S --noconfirm --needed \
    git \
    tig \
    neovim \
    npm \
    stow \
    fzf \
    ripgrep \
    direnv \
    bat \
    jq \
    zsh \
    zsh-syntax-highlighting \
    zsh-autosuggestions \
    zsh-theme-powerlevel10k \
    btop \
    kitty \
    unzip

  yay -S --answerclean N --answerdiff N --cleanafter --noremovemake --noconfirm --needed \
    navi ttf-jetbrains-mono-nerd
}

function stow_arch {
  local apparatus_dir="$1"
  local navi_dir=$(navi info config-path)
  navi_dir=${navi_dir%config.yaml}
  mkdir -p $navi_dir
  pushd . > /dev/null
  cd $apparatus_dir
  stow --restow --target="$HOME" zsh
  stow --restow --target="$HOME" git
  stow --restow --target="$HOME" tig
  stow --restow --target="$HOME" powerlevel10k
  stow --restow --target="$HOME/.config" kitty
  stow --restow --target="$HOME/.config" nvim
  stow --restow --target="$navi_dir" navi
  # stow --restow --target="$HOME/Google Drive/My Drive/Notes" obsidian
  popd > /dev/null
}

function unstow_arch {
  local apparatus_dir="$1"
  local navi_dir=$(navi info config-path)
  navi_dir=${navi_dir%config.yaml}
  pushd . > /dev/null
  cd $apparatus_dir
  stow --delete --target="$HOME" zsh
  stow --delete --target="$HOME" git
  stow --delete --target="$HOME" tig
  stow --delete --target="$HOME" powerlevel10k
  stow --delete --target="$HOME/.config" kitty
  stow --delete --target="$HOME/.config" nvim
  stow --delete --target="$navi_dir" navi
  # stow --delete --target="$HOME/Google Drive/My Drive/Notes" obsidian
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

  if [ -f "/etc/arch-release" ]; then
    DETECTED_OS="arch"
    return
  fi
}

function parse_opts {
  ALL=1
  while :
  do
    case "$1" in
      --check-support)
        CHECK_SUPPORT=1
        shift
        ;;
      --stow-only)
        STOW_ONLY=1
        ALL=
        shift
        ;;
      --unstow-only)
        UNSTOW_ONLY=1
        ALL=
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
      APPARATUS_DIR="$HOME/Workspace/github.com/liouk/apparatus"
      [[ -n "$ALL" ]] && install_macos
      [[ -n "$ALL" ]] && apparatus "$APPARATUS_DIR" "$HOME/.apparatus"
      [[ -n "$ALL" || -n "$STOW_ONLY" ]] && stow_macos "$APPARATUS_DIR"
      [[ -n "$UNSTOW_ONLY" ]] && unstow_macos "$APPARATUS_DIR" || :
      ;;

    fedora-server)
      APPARATUS_DIR="$HOME/.apparatus"
      [[ -n "$ALL" ]] && install_fedora_server
      [[ -n "$ALL" ]] && apparatus "$APPARATUS_DIR"
      [[ -n "$ALL" || -n "$STOW_ONLY" ]] && stow_fedora_server "$APPARATUS_DIR"
      [[ -n "$ALL" ]] && wrapup_linux
      [[ -n "$UNSTOW_ONLY" ]] && unstow_fedora_server "$APPARATUS_DIR" || :
      ;;

    arch)
      APPARATUS_DIR="$HOME/.apparatus"
      [[ -n "$ALL" ]] && install_arch
      [[ -n "$ALL" ]] && apparatus "$APPARATUS_DIR"
      [[ -n "$ALL" || -n "$STOW_ONLY" ]] && stow_arch "$APPARATUS_DIR"
      [[ -n "$ALL" ]] && wrapup_linux
      [[ -n "$UNSTOW_ONLY" ]] && unstow_arch "$APPARATUS_DIR" || :
      ;;

    *)
      echo "unsupported operating system (supported: macos, fedora-server)"
      exit 1
      ;;

  esac
}

main "$@"
