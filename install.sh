#!/usr/bin/env bash

set -e
set -o pipefail
[ -n "$TRACE" ] && { set -x; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

declare -A PKG_CMD
PKG_CMD[pacman]="sudo pacman -Syyu --noconfirm --needed"
PKG_CMD[yay]="yay -Sy --answerclean N --answerdiff N --cleanafter --noremovemake --noconfirm --needed"
PKG_CMD[brew]="brew install"
PKG_CMD[cask]="brew install --cask"

function read_lines {
  grep -v '^\s*#' "$1" | grep -v '^\s*$'
}

function detect_os {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    DETECTED_OS="macos"
    return
  fi

  if [ -f "/etc/arch-release" ]; then
    DETECTED_OS="arch"
    return
  fi
}

function install_packages {
  local platform_dir="$1"

  for pkg_file in "$platform_dir"/packages.*; do
    [ -f "$pkg_file" ] || continue
    local mgr="${pkg_file##*.}"
    local cmd="${PKG_CMD[$mgr]}"
    if [ -z "$cmd" ]; then
      echo "unknown package manager: $mgr"
      exit 1
    fi
    $cmd $(read_lines "$pkg_file" | tr '\n' ' ')
  done
}

function do_stow {
  local action="$1"
  local apparatus_dir="$2"
  local stow_file="$3"

  mkdir -p "$HOME/.config"
  pushd "$apparatus_dir" > /dev/null
  while IFS=: read -r target package; do
    [[ "$target" == "HOME" ]] && target="$HOME" || target="$HOME/$target"
    stow "$action" --target="$target" "$package"
  done < <(read_lines "$stow_file")
  popd > /dev/null
}

function apparatus {
  local installdir="$1"

  if [ -d "${installdir}" ]; then
    echo "will not clone apparatus; it already exists in $installdir"
    return
  fi

  git clone git@github.com:liouk/apparatus.git "$installdir"
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
      echo "unsupported operating system"
      exit 1
    fi
    echo "operating system supported ($DETECTED_OS)"
    exit 0
  fi

  local platform_dir="$SCRIPT_DIR/platforms/$DETECTED_OS"
  if [ ! -d "$platform_dir" ]; then
    echo "unsupported operating system"
    exit 1
  fi

  source "$platform_dir/config"

  if [ -n "$ALL" ]; then
    [ -f "$platform_dir/pre-install.sh" ] && source "$platform_dir/pre-install.sh"
    install_packages "$platform_dir"
    [ -f "$platform_dir/post-install.sh" ] && source "$platform_dir/post-install.sh"
    apparatus "$APPARATUS_DIR"
  fi

  if [ -n "$ALL" ] || [ -n "$STOW_ONLY" ]; then
    do_stow --restow "$APPARATUS_DIR" "$platform_dir/stow-targets"
  fi

  if [ -n "$UNSTOW_ONLY" ]; then
    do_stow --delete "$APPARATUS_DIR" "$platform_dir/stow-targets"
  fi
}

main "$@"
