#!/usr/bin/env bash

# Print the sink receiving playback as one JSON object. Prefer the sink with the
# most streams; use the default sink to break ties and while audio is idle.
set -euo pipefail

default_sink=$(pactl get-default-sink)
sinks=$(pactl -f json list sinks)
sink_inputs=$(pactl -f json list sink-inputs)

jq -cn \
	--arg default_sink "$default_sink" \
	--argjson sinks "$sinks" \
	--argjson sink_inputs "$sink_inputs" '
	[
		$sinks[] as $sink |
		([$sink_inputs[] | select(.sink == $sink.index)] | length) as $input_count |
		select($input_count > 0) |
		$sink + {
			input_count: $input_count,
			is_default: ($sink.name == $default_sink)
		}
	]
	| if length == 0 then
		([$sinks[] | select(.name == $default_sink)] | .[0])
	  else
		sort_by([.input_count, (if .is_default then 1 else 0 end)]) | last
	  end
	// empty
'
