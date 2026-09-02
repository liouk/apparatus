#!/bin/sh

set -eu

repo_url="${APPARATUS_REPO_URL:-git@github.com:liouk/apparatus.git}"

case "$(uname -s)" in
  Darwin)
    default_install_dir="$HOME/Workspace/github.com/liouk/apparatus"
    ;;
  Linux)
    if [ ! -r /etc/os-release ]; then
      echo "unsupported operating system" >&2
      exit 1
    fi
    . /etc/os-release
    if [ "${ID:-}" != "arch" ]; then
      echo "unsupported operating system: ${ID:-unknown}" >&2
      exit 1
    fi
    default_install_dir="$HOME/.apparatus"
    ;;
  *)
    echo "unsupported operating system: $(uname -s)" >&2
    exit 1
    ;;
esac

install_dir="${APPARATUS_INSTALL_DIR:-$default_install_dir}"

find_modern_bash() {
  for candidate in /opt/homebrew/bin/bash /usr/local/bin/bash "$(command -v bash 2>/dev/null || true)"; do
    [ -n "$candidate" ] || continue
    if [ -x "$candidate" ] && "$candidate" -c '((BASH_VERSINFO[0] >= 4))' 2>/dev/null; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  return 1
}

if ! bash_path="$(find_modern_bash)"; then
  echo "apparatus requires Bash 4 or newer." >&2
  echo "On macOS, install Homebrew Bash with: brew install bash" >&2
  exit 1
fi

if [ -e "$install_dir" ] && [ ! -d "$install_dir/.git" ]; then
  echo "will not clone apparatus; $install_dir exists but is not an apparatus checkout" >&2
  exit 1
fi

if [ ! -d "$install_dir/.git" ]; then
  command -v git > /dev/null 2>&1 || {
    echo "git is required to bootstrap apparatus" >&2
    exit 1
  }
  mkdir -p "$(dirname "$install_dir")"
  git clone "$repo_url" "$install_dir"
fi

exec "$bash_path" "$install_dir/install.sh" "$@"
