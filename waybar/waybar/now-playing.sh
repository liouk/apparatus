#!/usr/bin/env bash
artist="$(playerctl metadata artist)"
song="$(playerctl metadata title)"
[ -n "$artist" ] && artist="$artist - "
echo -n "{\"text\": \"$artist$song\"}"
