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

function ssh_keygen {
  command ssh-keygen "$@"
}

# Keep this paired with ssh_keygen when a platform selects another OpenSSH.
function ssh_version {
  command ssh -V
}

function ssh_supports_touch_policy {
  local version
  version="$(ssh_version 2>&1)"
  [[ "$version" =~ OpenSSH_([0-9]+)\.([0-9]+) ]] || return 1
  (( BASH_REMATCH[1] > 10 || (BASH_REMATCH[1] == 10 && BASH_REMATCH[2] >= 5) ))
}

function signing_key_fingerprints {
  cat "$SCRIPT_DIR/ssh-key.fingerprints"
  local extra="$HOME/.config/git/signing-key.fingerprints"
  if [[ -r "$extra" ]]; then
    printf '\n'
    cat "$extra"
  fi
}

function recover_ssh_keys (
  local answer pub fingerprint name key recovery_dir expected key_type
  local needs_recovery=false
  local -a recovered_keys=()
  umask 077
  mkdir -p "$HOME/.ssh"
  cd "$HOME/.ssh"

  # Recognize handles already downloaded locally before considering recovery.
  for pub in *.pub; do
    [[ -f "$pub" && -f "${pub%.pub}" ]] || continue
    fingerprint="$(ssh_keygen -lf "$pub" -E sha256 2>/dev/null | awk '{print $2}')" || continue
    name="$(awk -v fp="$fingerprint" '$2 == fp {print $1; exit}' < <(signing_key_fingerprints))"
    [[ -n "$name" ]] || continue
    key="${pub%.pub}"
    [[ "$key" == "$name" ]] && continue
    # Preserve existing aliases and their local signing policy.
    [[ -e "$name" || -L "$name" || -e "$name.pub" || -L "$name.pub" ]] && continue
    mv "$key" "$name"
    mv "$pub" "$name.pub"
  done

  while read -r name fingerprint; do
    [[ -z "$name" || "$name" == \#* ]] && continue
    if [[ ! -e "$name" && ! -L "$name" ]]; then
      needs_recovery=true
    elif [[ ! -r "$name" ]]; then
      apparatus_warning "warning: signing handle $name is unreadable; existing files preserved."
    fi
    if [[ -e "$name" || -L "$name" || -e "$name.pub" || -L "$name.pub" ]]; then
      expected="$fingerprint"
      fingerprint="$(ssh_keygen -lf "$name.pub" -E sha256 2>/dev/null | awk '{print $2}')" || fingerprint=
      if [[ "$fingerprint" != "$expected" ]]; then
        apparatus_warning "warning: $name has a missing or mismatched public fingerprint; existing files preserved."
      fi
    fi
  done < <(signing_key_fingerprints)

  if [[ "$needs_recovery" != true && "${FORCE_RECOVER_KEYS:-0}" != 1 ]]; then
    apparatus_message 'Signing handles already exist locally; skipping YubiKey recovery.'
    return 0
  fi
  if [[ "${YUBIKEY_NONINTERACTIVE:-0}" == 1 ]] || ! { exec 3<> /dev/tty; } 2> /dev/null; then
    apparatus_warning 'warning: YubiKey recovery requires a terminal; rerun --recover-keys-only interactively.'
    return 0
  fi
  apparatus_prompt 'Recover SSH keys from your YubiKey? [y/N] '
  read -r answer <&3 2>&3 || return 0
  [[ "$answer" == y || "$answer" == Y || "$answer" == yes ]] || return 0
  apparatus_prompt 'Plug in your YubiKey and press Enter when ready. '
  read -r answer <&3 2>&3 || return 0

  # Download all resident credentials in isolation, then import only configured
  # handles. Missing-key recovery must not replace existing local handles.
  recovery_dir="$(mktemp -d)"
  trap 'rm -rf -- "$recovery_dir"' EXIT
  (cd "$recovery_dir" && ssh_keygen -K <&3 >&3 2>&3) || return 1
  for pub in "$recovery_dir"/*.pub; do
    [[ -f "$pub" && -f "${pub%.pub}" ]] || continue
    fingerprint="$(ssh_keygen -lf "$pub" -E sha256 2>/dev/null | awk '{print $2}')" || continue
    name="$(awk -v fp="$fingerprint" '$2 == fp {print $1; exit}' < <(signing_key_fingerprints))"
    [[ -n "$name" ]] || continue
    if [[ "${FORCE_RECOVER_KEYS:-0}" != 1 ]] && { [[ -e "$name" || -L "$name" || -e "$name.pub" || -L "$name.pub" ]]; }; then
      apparatus_message "Preserving existing signing files for $name."
      continue
    fi
    mv -f "${pub%.pub}" "$name"
    mv -f "$pub" "$name.pub"
    recovered_keys+=("$name")
  done

  if (( ${#recovered_keys[@]} )); then
    if ! ssh_supports_touch_policy; then
      apparatus_warning 'warning: disabling signing-key touch requires OpenSSH 10.5 or newer; recovered handles still require touch.'
    else
      for name in "${recovered_keys[@]}"; do
        key_type="$(awk 'NR == 1 {print $1}' "$name.pub")"
        [[ "$key_type" == sk-* ]] || continue
        apparatus_message "Disabling touch for signing handle $name; reuse its passphrase when prompted to keep it."
        if ! ssh_keygen -p -O no-touch-required -f "$name" <&3 >&3 2>&3; then
          apparatus_warning "warning: could not disable touch for $name."
          return 1
        fi
      done
    fi
  fi
  while read -r name fingerprint; do
    [[ -z "$name" || "$name" == \#* ]] && continue
    if [[ ! -r "$name" ]]; then
      apparatus_warning "warning: signing handle $name is missing or unreadable. Signing remains enabled."
    fi
  done < <(signing_key_fingerprints)
)

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
      --force-recover-keys)
        FORCE_RECOVER_KEYS=1
        shift
        ;;
      --recover-keys-only)
        RECOVER_KEYS_ONLY=1
        FORCE_RECOVER_KEYS=1
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

  # Platform configuration owns this opt-in flag; do not inherit it from the
  # environment when the installer is invoked.
  unset MANAGE_PERSONAL_GIT_AND_SSH
  source "$platform_dir/config"

  if [ -n "$RECOVER_KEYS_ONLY" ]; then
    [[ "${MANAGE_PERSONAL_GIT_AND_SSH:-false}" == true ]] && recover_ssh_keys
    return
  fi

  if [ -n "$ALL" ]; then
    [ -f "$platform_dir/pre-install.sh" ] && source "$platform_dir/pre-install.sh"
    install_packages "$platform_dir"
    if [[ "${MANAGE_PERSONAL_GIT_AND_SSH:-false}" == true ]]; then
      ensure_github_auth_key
      recover_ssh_keys
      configure_apparatus_remote
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
