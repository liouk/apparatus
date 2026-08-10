#!/usr/bin/env bash

playing=""
paused=""

for p in $(playerctl -l 2>/dev/null); do
  pstatus=$(playerctl -p "$p" status 2>/dev/null)
  if [[ "$pstatus" == "Playing" && -z "$playing" ]]; then
    playing="$p"
  elif [[ "$pstatus" == "Paused" && -z "$paused" ]]; then
    paused="$p"
  fi
done

target="${playing:-$paused}"
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
