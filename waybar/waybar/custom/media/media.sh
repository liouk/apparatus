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
    if [[ -z "$playing" ]]; then
      icon=""
    elif [[ "$target" == spotify* ]]; then
      icon=""
    elif [[ "$target" == firefox* ]]; then
      icon=""
    else
      icon=""
    fi
    text=$(playerctl -p "$target" metadata --format '{{ artist }} - {{ title }}' | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')
    echo "$icon $text"
    ;;
  *)
    playerctl -p "$target" "$@"
    ;;
esac
