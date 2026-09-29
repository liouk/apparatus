#!/usr/bin/env bash

set -euo pipefail

readonly script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly adapter_root="$HOME/.local/share/zed/external_agents/registry/npx/codex-acp"
readonly adapter_file="$adapter_root/node_modules/@agentclientprotocol/codex-acp/dist/index.js"
readonly patch_file="$script_dir/codex-acp-show-command.patch"

[[ -f "$adapter_file" ]] || {
  printf 'Registry adapter not installed: %s\nStart Codex in Zed first.\n' "$adapter_root" >&2
  exit 1
}

if git -C "$adapter_root" apply --reverse --check "$patch_file" >/dev/null 2>&1; then
  exit 0
fi

git -C "$adapter_root" apply --whitespace=nowarn "$patch_file"
