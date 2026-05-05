#!/usr/bin/env bash

help() {
	cat <<-EOF
	Usage: vpn.sh [COMMAND] [ARGS]

	VPN Commands (Red Hat OpenVPN):
	   up              Start Red Hat VPN
	   down            Stop Red Hat VPN
	   status          Show Red Hat VPN status

	Tailscale Commands:
	   tailscale|tail  Manage Tailscale VPN
	      up [ARGS]       Start Tailscale (passes ARGS to 'tailscale up')
	      down            Stop Tailscale
	      status          Show Tailscale status

	Waybar Commands:
	   waybar-vpn      Output waybar JSON for Red Hat VPN
	   waybar-tailscale Output waybar JSON for Tailscale

	Other:
	   help            Show this message
	EOF
}

waybar_notify() {
	pkill -RTMIN+1 waybar
}

tailscale_cmd() {
	cmd="$1"
	shift
	case "$cmd" in
		up) tailscale up --reset --accept-dns=false "$@" && waybar_notify ;;
		down) tailscale down && waybar_notify ;;
		status)
			local parsed
			parsed=$(tailscale_parsed)
			case "${parsed:-off}" in
				off) echo "disconnected" ;;
				on) echo "connected" ;;
				exit*) echo "connected (exit node: $(echo "$parsed" | cut -f2), $(echo "$parsed" | cut -f3))" ;;
			esac
			;;
		*) echo "unknown command: '$cmd'" && exit 1 ;;
	esac
}

tailscale_parsed() {
	local status_output
	status_output=$(tailscale status --json 2>/dev/null) || return

	echo "$status_output" | jq -r '
		if .BackendState != "Running" then "off"
		elif (.ExitNodeStatus.Online // false) then
			(.ExitNodeStatus.ID) as $id |
			.Peer[] | select(.ID == $id) |
			"exit\t\(.HostName // "unknown")\t\(.Location.CountryCode // .Location.Country // "unknown")"
		else "on"
		end
	'
}

vpn_up() {
	sudo openvpn --daemon --config "${HOME}/liouk/redhat-config/redhat.ovpn"
	while ! ip addr show tun0 > /dev/null 2>&1; do
		sleep 0.5
	done
	waybar_notify
}

vpn_down() {
	sudo pkill -9 openvpn
	while ip addr show tun0 > /dev/null 2>&1; do
		sleep 0.5
	done
	waybar_notify
}

vpn_status() {
	if ip addr show tun0 > /dev/null 2>&1; then
		echo "connected"
	else
		echo "disconnected"
	fi
}

waybar_vpn() {
	if [[ $(vpn_status) == "connected" ]]; then
		echo '{"text": "󱄛", "class": "connected", "tooltip": "redhat vpn up"}'
	else
		echo '{"text": "󱄛", "class": "disconnected", "tooltip": "redhat vpn down"}'
	fi
}

waybar_tailscale() {
	local parsed
	parsed=$(tailscale_parsed)

	case "${parsed:-off}" in
		off) echo '{"text": "󱗼", "class": "disconnected", "tooltip": "tailscale down"}' ;;
		on) echo '{"text": "󱗼", "class": "connected", "tooltip": "tailscale up"}' ;;
		exit*)
			local hostname country_code
			hostname=$(echo "$parsed" | cut -f2)
			country_code=$(echo "$parsed" | cut -f3)
			echo "{\"text\": \"󱗼$country_code\", \"class\": \"connected\", \"tooltip\": \"tailscale up\nexit node: $hostname ($country_code)\"}"
			;;
	esac
}

main() {
	cmd="$1"
	shift
	case "$cmd" in
		up|down|status) { vpn_"$cmd" "$@"; return; } ;;
		tailscale|tail) { tailscale_cmd "$@"; return; } ;;
		waybar-vpn) { waybar_vpn; return; } ;;
		waybar-tailscale) { waybar_tailscale; return; } ;;
		help|-h|--help) { help; return; } ;;
		*) echo "unknown command: '$cmd'" && exit 1 ;;
	esac
}

main "$@"
