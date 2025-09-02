#!/usr/bin/env bash

tailscale_status() {
  local status_output
  status_output=$(tailscale status --json 2>/dev/null)

  if [[ $? -ne 0 ]] || [[ $(echo "$status_output" | jq -r '.BackendState') != "Running" ]]; then
    echo "{\"class\": \"disconnected\", \"tooltip\": \"tailscale down\"}"
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
    echo "{\"class\": \"connected\", \"text\": \"$country_code\", \"tooltip\": \"tailscale up\nexit node: $hostname ($country_code)\"}"
  else
    echo "{\"class\": \"connected\", \"tooltip\": \"tailscale up\"}"
  fi
}

vpn_status () {
  nmcli connection show --active | grep --quiet "$VPN_CONN_UUID"
}

vpn_statusjson () {
  status=""
  vpn_status && status="connected" || status="disconnected"
  echo "{\"class\": \"$status\", \"tooltip\": \"'$VPN_CONN_NAME' $status\"}"
}

vpn_toggle () {
  vpn_status && vpn_down || vpn_up
}

vpn_up () {
  nmcli connection up "$VPN_CONN_UUID" --ask
  pkill -RTMIN+1 waybar
}

vpn_down () {
  nmcli connection down "$VPN_CONN_UUID"
  pkill -RTMIN+1 waybar
}

main () {
  VPN_CONN_UUID=$(nmcli -g NAME,UUID,TYPE connection show | grep vpn | head -1 | cut -d':' -f2)
  VPN_CONN_NAME=$(nmcli -g NAME,UUID,TYPE connection show | grep vpn | head -1 | cut -d':' -f1)

  cmd="$1"
  case "$1" in
    status|statusjson|up|down|toggle) vpn_"$cmd" ;;
    tailscale_status) tailscale_status ;;
    "") cmd="status" ;;
    *) echo "unknown command: '$1'" && exit 1 ;;
  esac

}

main "$@"
