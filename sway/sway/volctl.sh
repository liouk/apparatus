#!/usr/bin/env bash

set -e

main () {
  all_sinks=$(pactl -f json list sinks|jq '.[] | "\(.state) \(.name)"')
  active_sink="@DEFAULT_SINK@"
  while read -r sink; do
    sink_status=(${sink//\"})
    sink_state="${sink_status[0]}"
    sink_name="${sink_status[1]}"

    if [[ "$sink_state" == "RUNNING" ]]; then
      active_sink="$sink_name"
    fi
  done <<< "$all_sinks"

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
