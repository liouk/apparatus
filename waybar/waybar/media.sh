#!/usr/bin/env bash

icon=""
for p in $(playerctl -l); do
	if [[ "$(playerctl -s -p $p status)" == "Playing" ]]; then
		if [[ "$p" == "spotify" ]]; then
			icon=""
		fi
		echo "$icon $(playerctl -s -p $p metadata --format '{{ artist }} - {{ title }}')"
		exit 0
	fi
done