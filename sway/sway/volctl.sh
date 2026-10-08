#!/usr/bin/env bash

set -euo pipefail

main() {
  local sink_data
  local active_sink
  local audio_volume

  sink_data=$("$HOME/.config/sway/active-sink.sh") || return
  active_sink=$(jq -r '.name // empty' <<<"$sink_data")
  [[ -n "$active_sink" ]] || return

  audio_volume=$(pactl get-sink-volume "$active_sink" | cut -d'/' -f2 | head -1 | xargs)
  case "$1" in
    up)
      if (( ${audio_volume%\%}+5 > 100 )); then
        pactl set-sink-volume "$active_sink" 100%
      else
        pactl set-sink-volume "$active_sink" +5%
      fi
      pactl set-sink-mute "$active_sink" 0
      ;;
    down)
      pactl set-sink-volume "$active_sink" -5%
      pactl set-sink-mute "$active_sink" 0
      ;;
    mute)
      pactl set-sink-mute "$active_sink" toggle
      ;;
    *)
      echo "invalid arg: '$1'"
      exit 1
      ;;
  esac
}

main "$@"
