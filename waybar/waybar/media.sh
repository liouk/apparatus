#!/usr/bin/env bash

icon=""
paused=
for p in $(playerctl -l); do
	case "$(playerctl -s -p $p status)" in
		"Playing")
			if [[ "$p" == "spotify" ]]; then
				icon=""
			fi
			echo "$icon $(playerctl -s -p $p metadata --format '{{ artist }} - {{ title }}')"
			exit 0
			;;
		"Paused")
			paused=1
			;;
	esac
done

if [[ -n "$paused" ]]; then
	icon=""
	echo "$icon $(playerctl -s -p $p metadata --format '{{ artist }} - {{ title }}')"
	exit 0
fi