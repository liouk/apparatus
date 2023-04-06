#!/usr/bin/env bash

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
    status|statusjson|up|down|toggle) ;;
    "") cmd="status" ;;
    *) echo "unknown command: '$1'" && exit 1 ;;
  esac

  vpn_"$cmd"
}

main "$@"
