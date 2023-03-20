#!/usr/bin/env bash

vpn_conn_uuid="e69b124b-50a8-4458-8859-5e68c3f19460"

vpn_status () {
  nmcli connection show --active | grep --quiet "$vpn_conn_uuid"
}

vpn_statusjson () {
  status=""
  vpn_status && status="connected" || status="disconnected"
  echo "{\"class\": \"$status\"}"
}

vpn_toggle () {
  vpn_status && vpn_down || vpn_up
}

vpn_up () {
  nmcli connection up "$vpn_conn_uuid" --ask
  pkill -RTMIN+1 waybar
}

vpn_down () {
  nmcli connection down "$vpn_conn_uuid"
  pkill -RTMIN+1 waybar
}

main () {
  cmd="$1"
  case "$1" in
    status|statusjson|up|down|toggle) ;;
    "") cmd="status" ;;
    *) echo "unknown command: '$1'" && exit 1 ;;
  esac

  vpn_"$cmd"
}

main "$@"
