#!/usr/bin/env bash

set -e
set -o pipefail
[ -n "$TRACE" ] && { set -x; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

  case "$DETECTED_OS" in
    macos)
      if [ -f "$platform_dir/packages.brew" ]; then
        brew install $(read_lines "$platform_dir/packages.brew" | tr '\n' ' ')
      fi
      if [ -f "$platform_dir/packages.cask" ]; then
        brew install --cask $(read_lines "$platform_dir/packages.cask" | tr '\n' ' ')
      fi
      ;;
    arch)
      if [ -f "$platform_dir/packages.pacman" ]; then
        sudo pacman -Syyu --noconfirm --needed $(read_lines "$platform_dir/packages.pacman" | tr '\n' ' ')
      fi
      if [ -f "$platform_dir/packages.yay" ]; then
        yay -Sy --answerclean N --answerdiff N --cleanafter --noremovemake --noconfirm --needed \
          $(read_lines "$platform_dir/packages.yay" | tr '\n' ' ')
      fi
      ;;
  esac
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
      echo "unsupported operating system (supported: macos, arch)"
      exit 1
    fi
    echo "operating system supported ($DETECTED_OS)"
    exit 0
  fi

  local platform_dir="$SCRIPT_DIR/platforms/$DETECTED_OS"
  if [ ! -d "$platform_dir" ]; then
    echo "unsupported operating system (supported: macos, arch)"
    exit 1
  fi

  local apparatus_dir
  case "$DETECTED_OS" in
    macos)  apparatus_dir="$HOME/Workspace/github.com/liouk/apparatus" ;;
    arch)   apparatus_dir="$HOME/.apparatus" ;;
  esac

  if [ -n "$ALL" ]; then
    [ -f "$platform_dir/pre-install.sh" ] && source "$platform_dir/pre-install.sh"
    install_packages "$platform_dir"
    [ -f "$platform_dir/post-install.sh" ] && source "$platform_dir/post-install.sh"
    apparatus "$apparatus_dir"
  fi

  if [ -n "$ALL" ] || [ -n "$STOW_ONLY" ]; then
    do_stow --restow "$apparatus_dir" "$platform_dir/stow-targets"
  fi

  if [ -n "$UNSTOW_ONLY" ]; then
    do_stow --delete "$apparatus_dir" "$platform_dir/stow-targets"
  fi
}

main "$@"
