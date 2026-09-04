#!/usr/bin/env bash

set -u

# Each executable in monitors.d must print one JSON object:
# {"state":"ok|alert|error", "text":"...", "tooltip":"...", "url":"..."}
# Only state is required. Fetching, parsing, and alert criteria belong to the monitor.
config_dir="${WEB_MONITOR_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/waybar-web-monitor/monitors.d}"
state_dir="${XDG_CACHE_HOME:-$HOME/.cache}/waybar-web-monitor"
state_file="$state_dir/waybar.json"
dismissed_file="$state_dir/dismissed.json"
dismiss_repaint_file="$state_dir/dismiss-repaint.json"
timeout_seconds="${WEB_MONITOR_TIMEOUT:-10}"
retry_delays="${WEB_MONITOR_RETRY_DELAYS-5 15}"

empty_result() {
	mkdir -p "$state_dir"
	jq -cn '{urls: [], active_fingerprints: []}' >"$state_file"
	jq -cn '[]' >"$dismissed_file"
	jq -cn '{text: "", class: "none", tooltip: ""}'
}

open_targets() {
	[[ -s "$state_file" ]] || return 0
	command -v xdg-open >/dev/null 2>&1 || return 1

	local url
	while IFS= read -r url; do
		[[ -n "$url" ]] || continue
		xdg-open "$url" >/dev/null 2>&1 &
	done < <(jq -r '.urls[]?' "$state_file")
}

dismiss_current() {
	mkdir -p "$state_dir"
	if [[ -s "$state_file" ]] && jq -e '.active_fingerprints | type == "array"' "$state_file" >/dev/null 2>&1; then
		jq -c '.active_fingerprints' "$state_file" >"$dismissed_file"
		jq -c '.urls = []' "$state_file" >"$dismiss_repaint_file"
	else
		jq -cn '[]' >"$dismissed_file"
		jq -cn '{urls: [], active_fingerprints: []}' >"$dismiss_repaint_file"
	fi
}

render_dismissed_once() {
	[[ -s "$dismiss_repaint_file" ]] || return 1
	mv "$dismiss_repaint_file" "$state_file"
	jq -cn '{text: "", class: "ok", tooltip: ""}'
}

error_result() {
	local name="$1"
	local message="$2"
	jq -cn --arg name "$name" --arg message "$message" \
		'{state: "error", text: "", tooltip: ($name + ": " + $message)}'
}

run_monitor() {
	local monitor="$1"
	local name
	local output
	local stderr_file
	name=$(basename "$monitor")
	stderr_file=$(mktemp)

	if command -v timeout >/dev/null 2>&1; then
		output=$(timeout "$timeout_seconds" "$monitor" 2>"$stderr_file")
	else
		output=$("$monitor" 2>"$stderr_file")
	fi
	local exit_code=$?

	if ((exit_code != 0)); then
		local message
		message=$(<"$stderr_file")
		[[ -n "$message" ]] || message="exited with status $exit_code"
		rm -f "$stderr_file"
		error_result "$name" "$message"
		return
	fi
	rm -f "$stderr_file"

	if ! jq -e '
		type == "object" and
		(.state == "ok" or .state == "alert" or .state == "error") and
		((.text // "") | type == "string") and
		((.tooltip // "") | type == "string") and
		((.url // "") | type == "string")
	' >/dev/null 2>&1 <<<"$output"; then
		error_result "$name" "invalid result"
		return
	fi

	jq -c --arg name "$name" '. + {name: $name}' <<<"$output"
}

render() {
	local results="$1"
	local active_fingerprints
	local dismissed='[]'
	local visible_results
	local rendered

	active_fingerprints=$(jq -c '
		def fingerprint: [.name, .state, (.text // ""), (.tooltip // ""), (.url // "")] | @json;
		[.[] | select(.state != "ok") | fingerprint]
	' <<<"$results")

	if [[ -s "$dismissed_file" ]] && jq -e 'type == "array" and all(.[]; type == "string")' "$dismissed_file" >/dev/null 2>&1; then
		dismissed=$(<"$dismissed_file")
	fi

	# Keep a dismissal only while that exact alert/error is still active. Recovery or
	# any change to its state, text, tooltip, or URL makes it eligible to appear again.
	dismissed=$(jq -cn --argjson dismissed "$dismissed" --argjson active "$active_fingerprints" '
		$dismissed | map(select(. as $item | $active | index($item)))
	')

	visible_results=$(jq -c --argjson dismissed "$dismissed" '
		def fingerprint: [.name, .state, (.text // ""), (.tooltip // ""), (.url // "")] | @json;
		map(select(.state == "ok" or (fingerprint as $item | ($dismissed | index($item) | not))))
	' <<<"$results")

	rendered=$(jq -c '
		def overall_state:
			if any(.[]; .state == "alert") then "alert"
			elif any(.[]; .state == "error") then "error"
			else "ok"
			end;

		(overall_state) as $state |
		([.[] | .text // "" | select(length > 0)] | join("  ")) as $text |
		{
			text: (
				if $text != "" then $text
				elif $state == "alert" then "󰀦 WEB"
				elif $state == "error" then "󰅙 WEB"
				else ""
				end
			),
			class: $state,
			tooltip: ([.[] | .tooltip // "" | select(length > 0)] | join("\n\n")),
			urls: [.[] | .url // "" | select(length > 0)]
		}
	' <<<"$visible_results")

	mkdir -p "$state_dir"
	jq -c --argjson active_fingerprints "$active_fingerprints" \
		'{urls, active_fingerprints: $active_fingerprints}' <<<"$rendered" >"$state_file"
	jq -c . <<<"$dismissed" >"$dismissed_file"
	jq -c 'del(.urls)' <<<"$rendered"
}

main() {
	if [[ "${1:-}" == "--open" ]]; then
		open_targets
		return
	fi
	if [[ "${1:-}" == "--dismiss" ]]; then
		dismiss_current
		return
	fi
	if render_dismissed_once; then
		return
	fi

	[[ -d "$config_dir" ]] || {
		empty_result
		return
	}

	local monitors=()
	local monitor_results=()
	local monitor
	while IFS= read -r -d '' monitor; do
		monitors+=("$monitor")
	done < <(find "$config_dir" -maxdepth 1 -type f -executable -print0 | sort -z)

	if ((${#monitors[@]} == 0)); then
		empty_result
		return
	fi

	local index
	for index in "${!monitors[@]}"; do
		monitor_results+=("$(run_monitor "${monitors[$index]}")")
	done

	# Resume can make Waybar run an overdue interval before networking is ready.
	# Retry only errors, in shared rounds, so healthy checks are never delayed and
	# simultaneous network failures wait only once per round.
	local retry_delay_values=()
	read -r -a retry_delay_values <<<"$retry_delays"
	local delay
	for delay in "${retry_delay_values[@]}"; do
		[[ "$delay" =~ ^[0-9]+([.][0-9]+)?$ ]] || continue

		local has_errors=false
		for index in "${!monitor_results[@]}"; do
			if jq -e '.state == "error"' >/dev/null 2>&1 <<<"${monitor_results[$index]}"; then
				has_errors=true
				break
			fi
		done
		[[ "$has_errors" == true ]] || break

		sleep "$delay"
		for index in "${!monitor_results[@]}"; do
			if jq -e '.state == "error"' >/dev/null 2>&1 <<<"${monitor_results[$index]}"; then
				monitor_results[$index]=$(run_monitor "${monitors[$index]}")
			fi
		done
	done

	local results
	results=$(printf '%s\n' "${monitor_results[@]}" | jq -sc '.')

	render "$results"
}

main "$@"
