#!/usr/bin/env bash

set -e

dp3="alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp_5__sink"
dp2="alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp_4__sink"
dp1="alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp_3__sink"
t14s="alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp__sink"
bose="bluez_output.2C_41_A1_4B_60_D1.1"
sc2i2="alsa_output.usb-Focusrite_Scarlett_2i2_USB_Y89QGYR9C2E15D-00.analog-stereo"

main () {
  all_sinks=$(pactl -f json list sinks|jq '.[] | "\(.state) \(.name)"')
  active_sink=""
  while read -r sink; do
    sink_status=(${sink//\"})
    sink_state="${sink_status[0]}"
    sink_name="${sink_status[1]}"

    if [[ "$sink_state" == "RUNNING" ]]; then
      active_sink="$sink_name"
    fi
  done <<< "$all_sinks"
  case "$active_sink" in
    "$t14s"|"") active_sink="@DEFAULT_SINK@" active_sink_disp="t14s" ;;
        "$dp1") active_sink_disp="DP-1" ;;
        "$dp2") active_sink_disp="DP-2" ;;
        "$dp3") active_sink_disp="DP-3" ;;
       "$bose") active_sink_disp="bose" ;;
      "$sc2i2") active_sink_disp="2i2"  ;;
             *) active_sink_disp="???" ;;
  esac

  audio_volume=$(pactl get-sink-volume "$active_sink" | cut -d'/' -f2 | head -1 | xargs)
  audio_is_muted=$(pactl get-sink-mute "$active_sink" | cut -d' ' -f2)

  case "$1" in
    get-vol)
      echo -n "$audio_volume ($active_sink_disp)"
      exit
      ;;
    get-mute)
      echo -n "$audio_is_muted"
      exit
      ;;
    up)
      pactl set-sink-volume "$active_sink" +5%
      pactl set-sink-mute "$active_sink" 0
      ;;
    down)
      pactl set-sink-volume "$active_sink" -5%
      pactl set-sink-mute "$active_sink" 0
      ;;
    mute)
      pactl set-sink-mute "$active_sink" toggle
      ;;
    *)
      echo "invalid arg: '$1'"
      exit 1
      ;;
  esac
}

main "$@"
