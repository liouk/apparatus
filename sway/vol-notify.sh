#!/usr/bin/env bash

set -e

case "$1" in
  up)
    pactl set-sink-volume @DEFAULT_SINK@ +5%
    pactl set-sink-mute @DEFAULT_SINK@ 0
    ;;
  down)
    pactl set-sink-volume @DEFAULT_SINK@ -5%
    pactl set-sink-mute @DEFAULT_SINK@ 0
    ;;
  mute)
    pactl set-sink-mute @DEFAULT_SINK@ toggle
    ;;
  *)
    echo "invalid arg: '$1'"
    exit 1
    ;;
esac

audio_volume=$(pactl get-sink-volume @DEFAULT_SINK@ | cut -d'/' -f2 | head -1 | xargs)
audio_is_muted=$(pactl get-sink-mute @DEFAULT_SINK@ | cut -d' ' -f2)

if [ $audio_is_muted = "yes" ]; then
  msg=" 󰖁 [                    ] 0%"
else
  num_stars=$((${audio_volume%"%"}/5))
  num_spaces=$((20-$num_stars))
  stars=$(printf "*%.0s" $(seq 1 $num_stars))
  spaces=$(printf " %.0s" $(seq 1 $num_spaces))

  if [ $num_stars -ge 20 ]; then
    stars="********************"
    spaces=""
  elif [ $num_stars -eq 0 ]; then
    stars=""
    spaces="                    "
  fi

  msg="  [$stars$spaces] $audio_volume"
fi

statefile="$HOME/.config/sway/.vol-notify.state"
nid=$(cat "$statefile" 2>/dev/null)
old_nid="$nid"
nid=$(notify-send "$msg" -p -r ${nid:=99999})
if [[ "$nid" -ne "$old_nid" ]]; then
  echo $nid > "$statefile"
fi
