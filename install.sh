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

function ssh_keygen {
  command ssh-keygen "$@"
}

function recover_ssh_keys (
  local answer pub fingerprint name expected
  umask 077
  mkdir -p "$HOME/.ssh"
  cd "$HOME/.ssh"
  if [[ "${YUBIKEY_NONINTERACTIVE:-0}" != 1 ]] && { exec 3<> /dev/tty; } 2> /dev/null; then
    read -r -p 'Recover SSH keys from your YubiKey? [y/N] ' answer <&3 2>&3 || return 0
    if [[ "$answer" == y || "$answer" == Y || "$answer" == yes ]]; then
      read -r -p 'Plug in your YubiKey and press Enter when ready. ' answer <&3 2>&3 || return 0
      ssh_keygen -K <&3 >&3 2>&3
    fi
  fi
  for pub in *.pub; do
    [[ -f "$pub" && -f "${pub%.pub}" ]] || continue
    fingerprint="$(ssh_keygen -lf "$pub" -E sha256 2>/dev/null | awk '{print $2}')" || continue
    name="$(awk -v fp="$fingerprint" '$2 == fp {print $1; exit}' "$SCRIPT_DIR/ssh-key.fingerprints")"
    [[ -n "$name" ]] || continue
    [[ -e "$name" || -L "$name" ]] || ln -s "${pub%.pub}" "$name"
    [[ -e "$name.pub" || -L "$name.pub" ]] || ln -s "$pub" "$name.pub"
  done
  while read -r name expected; do
    [[ -z "$name" || "$name" == \#* ]] && continue
    if [[ -e "$name" || -L "$name" || -e "$name.pub" || -L "$name.pub" ]]; then
      fingerprint="$(ssh_keygen -lf "$name.pub" -E sha256 2>/dev/null | awk '{print $2}')" || fingerprint=
      if [[ "$fingerprint" != "$expected" ]]; then
        echo "warning: $name has a missing or mismatched public fingerprint; existing files preserved." >&2
      fi
    fi
  done < "$SCRIPT_DIR/ssh-key.fingerprints"
  if [[ ! -r "$HOME/.ssh/id_ed25519_sk_git_signing_personal" ]]; then
    echo "warning: personal signing key is missing; recover it before committing. Signing remains enabled." >&2
  fi
)

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
      *) echo "unknown Stow layout: $layout" >&2; return 1 ;;
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
  local link_dir="${2:-/usr/local/bin}"
  local link_name target_spec target_path link_path
  local -a link_command=(ln)
  [ -f "$links_file" ] || return 0
  if [ "$link_dir" = /usr/local/bin ]; then
    link_command=(sudo ln)
  else
    mkdir -p "$link_dir"
  fi
  while IFS=: read -r link_name target_spec; do
    target_path="$(expand_path "$target_spec")"
    link_path="$link_dir/$link_name"
    if [ -L "$link_path" ]; then
      echo "link $link_path already exists; skipping"
    elif [ -e "$link_path" ]; then
      echo "will not create link $link_path; a non-symlink already exists" >&2
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
      --recover-keys-only)
        RECOVER_KEYS_ONLY=1
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

  if [ -n "$RECOVER_KEYS_ONLY" ]; then
    recover_ssh_keys
    return
  fi

  if [ -n "$ALL" ]; then
    [ -f "$platform_dir/pre-install.sh" ] && source "$platform_dir/pre-install.sh"
    install_packages "$platform_dir"
    recover_ssh_keys
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
