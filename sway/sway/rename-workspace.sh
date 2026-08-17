#!/usr/bin/env bash

current=$(swaymsg -t get_workspaces | jq -r '.[] | select(.focused) | .name')
current_num=$(swaymsg -t get_workspaces | jq -r '.[] | select(.focused) | .num')

current_label="${current#"$current_num"}"
current_label="${current_label#:}"

prompt="Rename sway workspace: "
value="$current_label"

printf '%s%s' "$prompt" "$value"

while IFS= read -r -s -n1 char; do
  case "$char" in
    $'\x1b')
      read -r -s -n1 -t 0.1 next
      if [ -z "$next" ]; then
        exit 0
      fi
      read -r -s -n1 -t 0.1
      ;;
    '')
      break
      ;;
    $'\x7f'|$'\b')
      if [ -n "$value" ]; then
        value="${value%?}"
        printf '\b \b'
      fi
      ;;
    *)
      value+="$char"
      printf '%s' "$char"
      ;;
  esac
done

if [ -n "$value" ]; then
  swaymsg "rename workspace \"$current\" to \"$current_num:$value\""
else
  swaymsg "rename workspace \"$current\" to \"$current_num\""
fi
