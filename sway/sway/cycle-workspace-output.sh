#!/bin/bash
# Cycle the focused workspace to the next active output
outputs=$(swaymsg -t get_outputs | jq -r '.[] | select(.active) | .name')
current=$(swaymsg -t get_workspaces | jq -r '.[] | select(.focused) | .output')
next=$(echo "$outputs" | sed -n "/${current}/{n;p;}" | head -1)
[ -z "$next" ] && next=$(echo "$outputs" | head -1)
swaymsg move workspace to output "$next"
