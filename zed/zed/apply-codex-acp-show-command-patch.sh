#!/usr/bin/env bash

set -euo pipefail

readonly adapter_root="$HOME/.local/share/zed/external_agents/registry/npx/codex-acp"
readonly adapter_file="$adapter_root/node_modules/@agentclientprotocol/codex-acp/dist/index.js"
readonly patch_file="$HOME/.config/zed/codex-acp-show-command.patch"

# Zed installs this registry package lazily. Nothing is needed until it exists.
[[ -f "$adapter_file" ]] || exit 0

if git -C "$adapter_root" apply --reverse --check "$patch_file" >/dev/null 2>&1; then
  exit 0
fi

git -C "$adapter_root" apply --whitespace=nowarn "$patch_file"
