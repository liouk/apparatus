#!/usr/bin/env bash

LAST_FILE="/tmp/media-last-player"
playing=""
paused=""
last=$(cat "$LAST_FILE" 2>/dev/null)

for p in $(playerctl -l 2>/dev/null); do
  pstatus=$(playerctl -p "$p" status 2>/dev/null)
  if [[ "$pstatus" == "Playing" && -z "$playing" ]]; then
    playing="$p"
  elif [[ "$pstatus" == "Paused" && -z "$paused" ]]; then
    paused="$p"
  fi
done

if [[ -n "$playing" ]]; then
  target="$playing"
  echo "$target" > "$LAST_FILE"
elif [[ -n "$last" ]] && playerctl -p "$last" status &>/dev/null; then
  target="$last"
else
  target="$paused"
fi
[[ -z "$target" ]] && exit 0

case "$1" in
  status)
    icon=""
    [[ "$target" == spotify* ]] && icon=""
    [[ -z "$playing" ]] && icon=""
    echo "$icon $(playerctl -p "$target" metadata --format '{{ artist }} - {{ title }}')"
    ;;
  *)
    playerctl -p "$target" "$@"
    ;;
esac
