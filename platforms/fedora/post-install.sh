#!/usr/bin/env bash

# Run in a subshell so temporary-file cleanup does not replace the driver's traps.
(
  set -e
  set -o pipefail
  fedora_tmp="$(mktemp -d -t apparatus-fedora.XXXXXXXX)"
  trap 'rm -rf -- "$fedora_tmp"' EXIT

  export PATH="$HOME/.local/bin:$PATH"
  mkdir -p "$HOME/.local/bin"

  # Keep CSB-provided installations. Otherwise use Zed's upstream stable installer.
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
  # An existing client may be managed by the CSB, so do not replace it.
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

  printf '\nFedora tools installed. Select Sway at the login screen when ready.\n'
  printf 'The managed desktop, audio services and login shell have not been changed.\n'
)

(
  umask 077
  mkdir -p "$HOME/.ssh"
  cd "$HOME/.ssh"
  if [[ "${YUBIKEY_NONINTERACTIVE:-0}" != 1 ]] && { exec 3<> /dev/tty; } 2> /dev/null; then
    read -r -p 'Recover SSH keys from your YubiKey? [y/N] ' answer <&3 2>&3 || exit 0
    if [[ "$answer" == y || "$answer" == Y || "$answer" == yes ]]; then
      read -r -p 'Plug in your YubiKey and press Enter when ready. ' answer <&3 2>&3 || exit 0
      ssh-keygen -K <&3 >&3 2>&3
    fi
  fi
  for pub in *.pub; do
    [[ -f "$pub" && -f "${pub%.pub}" ]] || continue
    fingerprint="$(ssh-keygen -lf "$pub" -E sha256 | awk '{print $2}')"
    name="$(awk -v fp="$fingerprint" '$2 == fp {print $1; exit}' "$SCRIPT_DIR/platforms/fedora/github-key.fingerprints")"
    [[ -n "$name" ]] || continue
    [[ -e "$name" || -L "$name" ]] || ln -sT "${pub%.pub}" "$name"
    [[ -e "$name.pub" || -L "$name.pub" ]] || ln -sT "$pub" "$name.pub"
  done
)

if [[ ! -e "$HOME/.ssh/config" && ! -L "$HOME/.ssh/config" ]]; then
  mkdir -p -m 700 "$HOME/.ssh"
  ln -sT "$SCRIPT_DIR/platforms/fedora/github-ssh.conf" "$HOME/.ssh/config"
else
  echo "Existing SSH config preserved; see platforms/fedora/github-ssh.conf for the GitHub settings."
fi
