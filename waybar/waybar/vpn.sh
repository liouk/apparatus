#!/usr/bin/env bash

waybar_notify() {
	pkill -RTMIN+1 waybar
}

tailscale_cmd() {
	cmd="$1"
	shift
	case "$cmd" in
		up) tailscale up "$@" && waybar_notify ;;
		down) tailscale down && waybar_notify ;;
		status) tailscale status ;;
		*) echo "unknown command: '$cmd'" && exit 1 ;;
	esac
}

tailscale_status() {
  local status_output
  status_output=$(tailscale status --json 2>/dev/null)

  if [[ $? -ne 0 ]] || [[ $(echo "$status_output" | jq -r '.BackendState') != "Running" ]]; then
    return
  fi

  local exit_node
  exit_node=$(echo "$status_output" | jq -r '.ExitNodeStatus.Online // false')

  if [[ "$exit_node" == "true" ]]; then
    local exit_node_id
    exit_node_id=$(echo "$status_output" | jq -r '.ExitNodeStatus.ID')
    local country_code hostname
    country_code=$(echo "$status_output" | jq -r --arg id "$exit_node_id" '.Peer[] | select(.ID == $id) | .Location.CountryCode // (.Location.Country // "unknown")')
    hostname=$(echo "$status_output" | jq -r --arg id "$exit_node_id" '.Peer[] | select(.ID == $id) | .HostName // "unknown"')
    echo "{\"text\": \"󱗼$country_code\", \"class\": \"connected\", \"tooltip\": \"tailscale up\nexit node: $hostname ($country_code)\"}"
  else
    echo "{\"text\": \"󱗼\", \"class\": \"connected\", \"tooltip\": \"tailscale up\"}"
  fi
}

vpn_up() {
	waybar_notify
}

vpn_down() {
	waybar_notify
}

vpn_status() {
	#echo "{\"text\": \"󱄛\", \"class\": \"connected\", \"tooltip\": \"redhat vpn up\"}"
	return
}

main() {
	cmd="$1"
	shift
	case "$cmd" in
		up|down|status) { vpn_"$cmd" "$@"; return; } ;;
		tailscale|tail) { tailscale_cmd "$@"; return; } ;;
		"") ;;
		*) echo "unknown command: '$cmd'" && exit 1 ;;
	esac

  local vpn_output
  vpn_output=$(vpn_status)
  if [[ -n "$vpn_output" ]]; then
    echo "$vpn_output"
    return
  fi

  local tailscale_output
  tailscale_output=$(tailscale_status)
  if [[ -n "$tailscale_output" ]]; then
    echo "$tailscale_output"
    return
  fi

  echo "{\"text\": \"\", \"class\": \"disconnected\", \"tooltip\": \"direct connection\"}"
}

main "$@"