#!/usr/bin/env bash

# Reports the active PulseAudio/PipeWire sink to Waybar. Bluetooth battery
# information is cached because querying BlueZ is comparatively expensive.
set -u

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/waybar-pulseaudio"
cache_max_age=60

battery_for_sink() {
	local sink="$1"
	local address
	local cache_file
	local cached_battery
	local cached_at
	local now
	local info
	local battery

	if [[ "$sink" =~ ^bluez_output\.([0-9A-Fa-f_]+)\. ]]; then
		address="${BASH_REMATCH[1]//_/:}"
	else
		return
	fi

	cache_file="$cache_dir/${address//:/_}"
	now=$(date +%s)
	if [[ -r "$cache_file" ]]; then
		read -r cached_at cached_battery <"$cache_file" || true
		if [[ "${cached_at:-}" =~ ^[0-9]+$ ]] && ((now - cached_at < cache_max_age)); then
			printf '%s\n' "${cached_battery:-}"
			return
		fi
	fi

	info=$(bluetoothctl info "$address" 2>/dev/null) || return
	battery=$(sed -n 's/.*Battery Percentage:.*(\([0-9][0-9]*\)).*/\1/p' <<<"$info" | head -n 1)
	mkdir -p "$cache_dir"
	printf '%s %s\n' "$now" "$battery" >"$cache_file"
	printf '%s\n' "$battery"
}

main() {
	local sink
	local sink_data
	local description
	local volume
	local muted
	local battery
	local icon
	local text
	local tooltip
	local class='[]'

	sink=$(pactl get-default-sink 2>/dev/null) || return
	[[ -n "$sink" ]] || return

	sink_data=$(pactl -f json list sinks 2>/dev/null) || return
	description=$(jq -r --arg sink "$sink" '.[] | select(.name == $sink) | .description // $sink' <<<"$sink_data" | head -n 1)
	[[ -n "$description" && "$description" != "null" ]] || description="$sink"
	volume=$(pactl get-sink-volume "$sink" 2>/dev/null | grep -oE '[0-9]+%' | head -n 1)
	muted=$(pactl get-sink-mute "$sink" 2>/dev/null | awk '{print $2}')
	[[ -n "$volume" ]] || volume='0%'

	if [[ "$muted" == 'yes' ]]; then
		icon='󰖁'
		class='["muted"]'
	elif [[ "$sink" == bluez_output.* ]]; then
		icon=''
		class='["bluetooth"]'
	else
		case "${volume%%%}" in
			[0-2]?|[0-9]) icon='' ;;
			[3-6]?) icon='' ;;
			*) icon='' ;;
		esac
	fi

	text="$icon $volume"
	tooltip="$description"
	if [[ "$sink" == bluez_output.* ]]; then
		battery=$(battery_for_sink "$sink")
		if [[ -n "$battery" ]]; then
			tooltip="$description ( $battery%)"
		fi
	fi

	jq -cn --arg text "$text" --arg tooltip "$tooltip" --argjson class "$class" \
		'{text: $text, tooltip: $tooltip, class: $class}'
}

main
