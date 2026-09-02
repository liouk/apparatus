#!/usr/bin/env bash

if ((BASH_VERSINFO[0] < 4)); then
  echo "apparatus requires Bash 4 or newer (found $BASH_VERSION)" >&2
  echo "On macOS, install it with Homebrew and rerun this script with Homebrew's bash." >&2
  exit 1
fi

set -e
set -o pipefail
[ -n "$TRACE" ] && { set -x; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

function read_lines {
  local line trimmed
  while IFS= read -r line || [ -n "$line" ]; do
    trimmed="${line#"${line%%[![:space:]]*}"}"
    trimmed="${trimmed%"${trimmed##*[![:space:]]}"}"
    [[ -z "$trimmed" || "$trimmed" == \#* ]] && continue
    printf '%s\n' "$trimmed"
  done < "$1"
}

function expand_path {
  case "$1" in
    '$HOME')
      printf '%s\n' "$HOME"
      ;;
    '$HOME/'*)
      printf '%s/%s\n' "$HOME" "${1#\$HOME/}"
      ;;
    '~')
      printf '%s\n' "$HOME"
      ;;
    '~/'*)
      printf '%s/%s\n' "$HOME" "${1#\~/}"
      ;;
    *)
      printf '%s\n' "$1"
      ;;
  esac
}

function detect_os {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    DETECTED_OS="macos"
  elif [ -f /etc/os-release ]; then
    DETECTED_OS=$(. /etc/os-release && echo "$ID")
  fi
}

function install_packages {
  local platform_dir="$1"
  local pkg_file mgr installer
  local -a packages

  for pkg_file in "$platform_dir"/packages.*; do
    [ -f "$pkg_file" ] || continue
    mgr="${pkg_file##*.}"
    installer="install_${mgr}_packages"
    if ! declare -F "$installer" > /dev/null; then
      echo "unknown package manager: $mgr"
      exit 1
    fi
    mapfile -t packages < <(read_lines "$pkg_file")
    [ "${#packages[@]}" -eq 0 ] || "$installer" "${packages[@]}"
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

function clone_repos {
  local repos_file="$1"
  local target_spec target_dir git_url remainder
  [ -f "$repos_file" ] || return 0
  while read -r target_spec git_url remainder; do
    if [ -n "$remainder" ]; then
      echo "invalid repository entry: $target_spec $git_url $remainder" >&2
      exit 1
    fi
    target_dir="$(expand_path "$target_spec")"
    if [ -d "$target_dir" ]; then
      echo "will not clone $git_url; $target_dir already exists"
    else
      mkdir -p "$(dirname "$target_dir")"
      git clone "$git_url" "$target_dir"
    fi
  done < <(read_lines "$repos_file")
}

function create_links {
  local links_file="$1"
  local link_name target_spec target_path link_path
  [ -f "$links_file" ] || return 0
  while IFS=: read -r link_name target_spec; do
    target_path="$(expand_path "$target_spec")"
    link_path="/usr/local/bin/$link_name"
    if [ -L "$link_path" ]; then
      echo "link $link_path already exists; skipping"
    elif [ -e "$link_path" ]; then
      echo "will not create link $link_path; a non-symlink already exists" >&2
      exit 1
    else
      sudo ln -s "$target_path" "$link_path"
    fi
  done < <(read_lines "$links_file")
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
    if [ -z "$DETECTED_OS" ] || [ ! -d "$SCRIPT_DIR/platforms/$DETECTED_OS" ]; then
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
    clone_repos "$platform_dir/repos"
    create_links "$platform_dir/links"
    [ -f "$platform_dir/post-install.sh" ] && source "$platform_dir/post-install.sh"
  fi

  if [ -n "$ALL" ] || [ -n "$STOW_ONLY" ]; then
    do_stow --restow "$SCRIPT_DIR" "$platform_dir/stow-targets"
  fi

  if [ -n "$UNSTOW_ONLY" ]; then
    do_stow --delete "$SCRIPT_DIR" "$platform_dir/stow-targets"
  fi
}

main "$@"
