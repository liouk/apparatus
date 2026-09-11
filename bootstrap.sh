#!/bin/sh

set -eu

if [ -t 1 ] || [ -t 2 ]; then
  APPARATUS_PREFIX="$(printf '\033[1;3;34m[apparatus]\033[0m')"
else
  APPARATUS_PREFIX='[apparatus]'
fi

apparatus_message() { printf '%s %s\n' "$APPARATUS_PREFIX" "$*"; }
apparatus_warning() { printf '%s %s\n' "$APPARATUS_PREFIX" "$*" >&2; }

repo_url="${APPARATUS_REPO_URL:-https://github.com/liouk/apparatus.git}"
raw_url="${APPARATUS_RAW_URL:-https://raw.githubusercontent.com/liouk/apparatus/master}"

case "$(uname -s)" in
  Darwin)
    platform_id=macos
    ;;
  Linux)
    if [ ! -r /etc/os-release ]; then
      apparatus_warning "unsupported operating system"
      exit 1
    fi
    . /etc/os-release
    platform_id="${ID:-}"
    ;;
  *)
    apparatus_warning "unsupported operating system: $(uname -s)"
    exit 1
    ;;
esac

case "$platform_id" in
  ''|*[!a-z0-9_-]*) apparatus_warning "invalid platform ID: $platform_id"; exit 1 ;;
esac

bash_candidates=
bash_hint="Install Bash 4 or newer and rerun the bootstrap."
bootstrap_prepare() { :; }

find_modern_bash() {
  for candidate in $bash_candidates "$(command -v bash 2>/dev/null || true)"; do
    [ -n "$candidate" ] || continue
    if [ -x "$candidate" ] && "$candidate" -c '((BASH_VERSINFO[0] >= 4))' 2>/dev/null; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  return 1
}

# Use the matching local platform file when running from a checkout. A piped
# bootstrap downloads it first because Git and the checkout may not exist yet.
bootstrap_dir="$(CDPATH= cd "$(dirname "$0")" && pwd)"
bootstrap_download=
if [ -f "$0" ] && [ -f "$bootstrap_dir/install.sh" ]; then
  platform_bootstrap="$bootstrap_dir/platforms/$platform_id/bootstrap.sh"
else
  bootstrap_download="$(mktemp -t apparatus-bootstrap.XXXXXXXX)"
  trap 'rm -f "$bootstrap_download"' EXIT
  platform_bootstrap="$bootstrap_download"
  curl -fsSL "$raw_url/platforms/$platform_id/bootstrap.sh" -o "$platform_bootstrap"
fi
if [ ! -r "$platform_bootstrap" ]; then
  apparatus_warning "unsupported platform: $platform_id"
  exit 1
fi
. "$platform_bootstrap"
if [ -n "$bootstrap_download" ]; then
  rm -f "$bootstrap_download"
  trap - EXIT
fi

install_dir="${APPARATUS_INSTALL_DIR:-$default_install_dir}"
if [ -e "$install_dir" ] && [ ! -d "$install_dir/.git" ]; then
  apparatus_warning "will not clone apparatus; $install_dir exists but is not an apparatus checkout"
  exit 1
fi

bootstrap_prepare

if ! bash_path="$(find_modern_bash)"; then
  apparatus_warning "apparatus requires Bash 4 or newer."
  apparatus_warning "$bash_hint"
  exit 1
fi

if [ ! -d "$install_dir/.git" ]; then
  command -v git > /dev/null 2>&1 || {
    apparatus_warning "git is required to bootstrap apparatus"
    exit 1
  }
  mkdir -p "$(dirname "$install_dir")"
  git clone "$repo_url" "$install_dir"
fi

exec "$bash_path" "$install_dir/install.sh" "$@"
