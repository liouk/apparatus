#!/usr/bin/env bash

if ((BASH_VERSINFO[0] < 4)); then
  printf '[apparatus] apparatus requires Bash 4 or newer (found %s)\n' "$BASH_VERSION" >&2
  printf '[apparatus] On macOS, install it with Homebrew and rerun this script with Homebrew Bash.\n' >&2
  exit 1
fi

set -e
set -o pipefail
[ -n "$TRACE" ] && { set -x; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -t 1 || -t 2 ]]; then
  APPARATUS_PREFIX=$'\033[1;3;34m[apparatus]\033[0m'
else
  APPARATUS_PREFIX='[apparatus]'
fi

function apparatus_message {
  printf '%s %s\n' "$APPARATUS_PREFIX" "$*"
}

function apparatus_warning {
  printf '%s %s\n' "$APPARATUS_PREFIX" "$*" >&2
}

function apparatus_prompt {
  printf '%s %s' "$APPARATUS_PREFIX" "$1" >&3
}

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

function ensure_github_auth_key {
  local key_path="${HOME}/.ssh/id_ed25519_github"
  local answer
  [[ -r "$key_path" && -r "$key_path.pub" ]] && return 0
  if [[ -e "$key_path" || -e "$key_path.pub" ]]; then
    apparatus_warning "GitHub SSH key files are incomplete; existing files preserved."
    return 0
  fi
  if [[ "${YUBIKEY_NONINTERACTIVE:-0}" == 1 ]] || ! { exec 3<> /dev/tty; } 2> /dev/null; then
    apparatus_warning "GitHub SSH key is missing; rerun interactively to create it."
    return 0
  fi
  apparatus_prompt 'Create a local SSH authentication key for GitHub? [y/N] '
  read -r answer <&3 2>&3 || return 0
  if [[ "$answer" == y || "$answer" == Y || "$answer" == yes ]]; then
    ssh-keygen -t ed25519 -f "$key_path" -C "github-auth-$(uname -n)" <&3 >&3 2>&3
    apparatus_message "Add $key_path.pub to your GitHub account as an authentication key."
  fi
}

function configure_apparatus_remote {
  local remote_url
  remote_url="$(git -C "$SCRIPT_DIR" remote get-url origin 2>/dev/null || true)"
  case "$remote_url" in
    https://github.com/liouk/apparatus|https://github.com/liouk/apparatus.git)
      [[ -r "$HOME/.ssh/id_ed25519_github" ]] || return 0
      git -C "$SCRIPT_DIR" remote set-url origin git@github.com:liouk/apparatus.git
      apparatus_message "Switched the Apparatus remote to SSH."
      ;;
  esac
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
      apparatus_warning "unknown package manager: $mgr"
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
  local target package package_dir layout
  local -a stow_options

  mkdir -p "$HOME/.config"
  pushd "$apparatus_dir" > /dev/null
  while IFS=: read -r target package layout; do
    case "$target" in
      HOME) target="$HOME" ;;
      CODEX) target="${CODEX_HOME:-$HOME/.codex}"; mkdir -p "$target" ;;
      *) target="$HOME/$target" ;;
    esac
    stow_options=()
    case "$layout" in
      '') ;;
      no-folding) stow_options+=(--no-folding) ;;
      *) apparatus_warning "unknown Stow layout: $layout"; return 1 ;;
    esac
    # Manifests can refer to shared or platform-local packages, relative to the checkout.
    package_dir="$apparatus_dir/$(dirname "$package")"
    stow "$action" "${stow_options[@]}" --dir="$package_dir" --target="$target" "$(basename "$package")"
  done < <(read_lines "$stow_file")
  popd > /dev/null
}

function clone_repos {
  local repos_file="$1"
  local target_spec target_dir git_url remainder
  [ -f "$repos_file" ] || return 0
  while read -r target_spec git_url remainder; do
    if [ -n "$remainder" ]; then
      apparatus_warning "invalid repository entry: $target_spec $git_url $remainder"
      exit 1
    fi
    target_dir="$(expand_path "$target_spec")"
    if [ -d "$target_dir" ]; then
      apparatus_message "will not clone $git_url; $target_dir already exists"
    else
      mkdir -p "$(dirname "$target_dir")"
      git clone "$git_url" "$target_dir"
    fi
  done < <(read_lines "$repos_file")
}

function create_links {
  local links_file="$1"
  local link_dir="${2:-/usr/local/bin}"
  local link_name target_spec target_path link_path
  local -a link_command=(ln)
  [ -f "$links_file" ] || return 0
  if [ "$link_dir" = /usr/local/bin ]; then
    apparatus_message "Creating links in $link_dir requires sudo; enter your password for sudo when prompted."
    link_command=(sudo -p 'apparatus: enter your password for sudo: ' ln)
  else
    mkdir -p "$link_dir"
  fi
  while IFS=: read -r link_name target_spec; do
    target_path="$(expand_path "$target_spec")"
    link_path="$link_dir/$link_name"
    if [ -L "$link_path" ]; then
      apparatus_message "link $link_path already exists; skipping"
    elif [ -e "$link_path" ]; then
      apparatus_warning "will not create link $link_path; a non-symlink already exists"
      exit 1
    else
      "${link_command[@]}" -s "$target_path" "$link_path"
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
        apparatus_warning "unexpected option: $1"
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
      apparatus_warning "unsupported operating system"
      exit 1
    fi
    apparatus_message "operating system supported ($DETECTED_OS)"
    exit 0
  fi

  local platform_dir="$SCRIPT_DIR/platforms/$DETECTED_OS"
  if [ ! -d "$platform_dir" ]; then
    apparatus_warning "unsupported operating system"
    exit 1
  fi

  # Platform configuration owns these opt-in flags; do not inherit them from the
  # environment when the installer is invoked.
  MANAGE_GITHUB_SSH_AUTH=false
  source "$platform_dir/config"

  if [ -n "$ALL" ]; then
    [ -f "$platform_dir/pre-install.sh" ] && source "$platform_dir/pre-install.sh"
    install_packages "$platform_dir"
    if [[ "$MANAGE_GITHUB_SSH_AUTH" == true ]]; then
      ensure_github_auth_key
      configure_apparatus_remote
    fi
    if [[ -f "$platform_dir/git-signing.sh" ]]; then
      if ! bash "$platform_dir/git-signing.sh"; then
        apparatus_warning "warning: Git signing setup failed; rerun bash platforms/$DETECTED_OS/git-signing.sh."
      fi
    fi
    clone_repos "$platform_dir/repos"
    create_links "$platform_dir/links" "${APPARATUS_BIN_DIR:-/usr/local/bin}"
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
