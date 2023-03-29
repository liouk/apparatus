#!/usr/bin/env bash

workspaces=($(swaymsg -t get_workspaces | jq ".[] | .num" | sort | xargs))
next=1
for ws in ${workspaces[@]}; do
  [ "$ws" -ne "$next" ] && break
  ((next = next + 1))
done
echo -n $next
