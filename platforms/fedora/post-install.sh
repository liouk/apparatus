#!/usr/bin/env bash

# Run in a subshell so temporary-file cleanup does not replace the driver's traps.
(
  set -e
  set -o pipefail
  fedora_tmp="$(mktemp -d -t apparatus-fedora.XXXXXXXX)"
  trap 'rm -rf -- "$fedora_tmp"' EXIT

  export PATH="$HOME/.local/bin:$PATH"
  mkdir -p "$HOME/.local/bin"

  # Keep existing installations. Otherwise use Zed's upstream stable installer.
  if ! command -v zeditor > /dev/null && ! command -v zed > /dev/null; then
    curl -fsSL https://zed.dev/install.sh -o "$fedora_tmp/zed-install.sh"
    sh "$fedora_tmp/zed-install.sh"
  fi
  # Shared Sway config and toolshed use Arch's executable name.
  if ! command -v zeditor > /dev/null; then
    zed_path="$(command -v zed)"
    if [ -e "$HOME/.local/bin/zeditor" ] || [ -L "$HOME/.local/bin/zeditor" ]; then
      echo "Cannot create $HOME/.local/bin/zeditor: an unusable file/link already exists." >&2
      exit 1
    fi
    ln -s "$zed_path" "$HOME/.local/bin/zeditor"
  fi

  # Latest stable kubectl, verified against upstream's SHA-256 checksum.
  # An existing client may be system-managed, so do not replace it.
  if ! command -v kubectl > /dev/null; then
    case "$(uname -m)" in
      x86_64) kubectl_arch=amd64 ;;
      aarch64) kubectl_arch=arm64 ;;
      *) echo "Unsupported kubectl architecture" >&2; exit 1 ;;
    esac
    kubectl_version="$(curl -fsSL https://dl.k8s.io/release/stable.txt)"
    if [[ ! "$kubectl_version" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      echo "Invalid upstream kubectl version: $kubectl_version" >&2
      exit 1
    fi
    kubectl_url="https://dl.k8s.io/release/$kubectl_version/bin/linux/$kubectl_arch/kubectl"
    curl -fsSL "$kubectl_url" -o "$fedora_tmp/kubectl"
    curl -fsSL "$kubectl_url.sha256" -o "$fedora_tmp/kubectl.sha256"
    (
      cd "$fedora_tmp"
      printf '%s  kubectl\n' "$(< kubectl.sha256)" | sha256sum --check
    )
    install -m 0755 "$fedora_tmp/kubectl" "$HOME/.local/bin/kubectl"
  fi

  # Match the symbols release used by the Arch platform, without system font writes.
  if ! fc-match -f '%{family}\n' 'Symbols Nerd Font Mono' | rg -q '^Symbols Nerd Font Mono$'; then
    curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.0/NerdFontsSymbolsOnly.zip \
      -o "$fedora_tmp/NerdFontsSymbolsOnly.zip"
    unzip -q "$fedora_tmp/NerdFontsSymbolsOnly.zip" '*.ttf' -d "$fedora_tmp/fonts"
    font_dir="$HOME/.local/share/fonts/NerdFontsSymbolsOnly"
    mkdir -p "$font_dir"
    install -m 0644 "$fedora_tmp"/fonts/*.ttf "$font_dir/"
    fc-cache -f "$font_dir"
  fi

  # Maple Mono NL NF, used by Foot, Waybar and Zed.
  if ! fc-match -f '%{family}\n' 'Maple Mono NL NF' | rg -q '^Maple Mono NL NF$'; then
    maple_version=7.9
    maple_archive="$fedora_tmp/MapleMonoNL-NF-$maple_version.zip"
    curl -fsSL "https://github.com/subframe7536/maple-font/releases/download/v$maple_version/MapleMonoNL-NF-$maple_version.zip" \
      -o "$maple_archive"
    printf '%s  %s\n' \
      f6b2c6d1981ca338729449dba0caf07ba05751edd1d4b474b46d7b316b3c0db3 \
      "$maple_archive" | sha256sum --check
    unzip -q "$maple_archive" '*.ttf' -d "$fedora_tmp/maple-fonts"
    maple_font_dir="$HOME/.local/share/fonts/MapleMonoNL-NF"
    mkdir -p "$maple_font_dir"
    install -m 0644 "$fedora_tmp"/maple-fonts/*.ttf "$maple_font_dir/"
    fc-cache -f "$maple_font_dir"
  fi

  printf '\nFedora tools installed. Select Sway at the login screen when ready.\n'
  printf 'The managed desktop, audio services and login shell have not been changed.\n'
)

if [[ ! -e "$HOME/.ssh/config" && ! -L "$HOME/.ssh/config" ]]; then
  mkdir -p -m 700 "$HOME/.ssh"
  ln -sT "$SCRIPT_DIR/platforms/fedora/github-ssh.conf" "$HOME/.ssh/config"
else
  echo "Existing SSH config preserved; see platforms/fedora/github-ssh.conf for the GitHub settings."
fi
