#!/usr/bin/env bash

function configure_macos_git_signing {
  local git_config="$HOME/.config/git/platform.conf"
  local native_key="$MACOS_NATIVE_SIGNING_KEY"
  local agent_label="com.liouk.apparatus.git-signing"
  local agent_plist="$HOME/Library/LaunchAgents/$agent_label.plist"
  local domain="gui/$(id -u)"
  local openssh_prefix

  # Refuse to follow links when writing generated configuration.
  if [[ -L "$git_config" || ( -e "$git_config" && ! -f "$git_config" ) ]]; then
    apparatus_warning "will not modify symlink or non-file: $git_config"
    return 1
  fi
  mkdir -p "$HOME/.config/git"

  if [[ ! -r "$native_key" || ! -r "$native_key.pub" ]]; then
    # Preserve a previously selected signing key if its handle is unavailable.
    if git config --file "$git_config" --get user.signingkey >/dev/null 2>&1; then
      apparatus_warning "warning: native signing handle is missing; existing $git_config preserved."
      return 0
    fi
    # Keep the existing YubiKey setup on Macs without a native identity.
    openssh_prefix="$(brew --prefix openssh)"
    git config --file "$git_config" gpg.ssh.program "$openssh_prefix/bin/ssh-keygen"
    return 0
  fi

  if [[ -L "$agent_plist" || ( -e "$agent_plist" && ! -f "$agent_plist" ) ]]; then
    apparatus_warning "will not modify symlink or non-file: $agent_plist"
    return 1
  fi
  # This file is included after personal/work identity routing.
  git config --file "$git_config" gpg.ssh.program /usr/bin/ssh-keygen
  git config --file "$git_config" user.signingkey "$native_key.pub"

  mkdir -p "$HOME/Library/LaunchAgents"
  cp "$SCRIPT_DIR/platforms/macos/git-signing.plist" "$agent_plist"
  /usr/bin/plutil -lint "$agent_plist" >/dev/null
  if /bin/launchctl print "$domain" >/dev/null 2>&1; then
    if /bin/launchctl print "$domain/$agent_label" >/dev/null 2>&1; then
      /bin/launchctl kickstart "$domain/$agent_label"
    else
      /bin/launchctl bootstrap "$domain" "$agent_plist"
    fi
  else
    apparatus_warning 'warning: no GUI login session; the signing handle will load at the next graphical login.'
  fi
  apparatus_message 'Native Mac signing configured; the signing handle loads automatically at login.'
}

configure_macos_git_signing
