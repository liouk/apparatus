#!/usr/bin/env bash

# Print the next timed Google Calendar event remaining today in Zurich.
#
# The OAuth client credentials live at ~/.config/waybar/credentials.json. Run
# this script once with --authorize; its refresh token is stored outside this
# repository under ~/.local/share/waybar-google-calendar/token.json.

set -uo pipefail

readonly time_zone='Europe/Zurich'
readonly scope='https://www.googleapis.com/auth/calendar.events.readonly'
readonly credentials_file="${WAYBAR_GOOGLE_CALENDAR_CREDENTIALS:-$HOME/.config/waybar/google-calendar-credentials.json}"
readonly data_dir="${XDG_DATA_HOME:-$HOME/.local/share}/waybar-google-calendar"
readonly cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/waybar-google-calendar"
readonly token_file="$data_dir/token.json"
readonly events_cache_file="$cache_dir/events.json"
readonly event_file="$cache_dir/next-event.json"
readonly callback_port="${WAYBAR_GOOGLE_CALENDAR_CALLBACK_PORT:-53682}"
readonly max_text_length=36
readonly fetch_interval_seconds=3600
readonly imminent_interval_seconds=1800
readonly urgent_interval_seconds=600

error() {
	printf '%s\n' "$*" >&2
}

write_private_json() {
	local destination="$1"
	local content="$2"
	local temporary

	umask 077
	mkdir -p "$(dirname "$destination")"
	temporary=$(mktemp "${destination}.XXXXXX") || return
	printf '%s\n' "$content" >"$temporary"
	mv "$temporary" "$destination"
}

emit() {
	local text="$1"
	local tooltip="$2"
	local classes="$3"

	jq -cn --arg text "$text" --arg tooltip "$tooltip" --argjson class "$classes" \
		'{text: $text, tooltip: $tooltip, class: $class}'
}

credentials() {
	[[ -r "$credentials_file" ]] || {
		error "credentials file not found: $credentials_file"
		return 1
	}

	jq -e '.installed | select(type == "object" and .client_id and .client_secret)' "$credentials_file"
}

refresh_access_token() {
	local client="$1"
	local refresh_token="$2"
	local client_id client_secret token_uri response now expires_at saved_token

	client_id=$(jq -r '.client_id' <<<"$client")
	client_secret=$(jq -r '.client_secret' <<<"$client")
	token_uri=$(jq -r '.token_uri // "https://oauth2.googleapis.com/token"' <<<"$client")
	response=$(curl --fail-with-body --silent --show-error --request POST "$token_uri" \
		--data-urlencode "client_id=$client_id" \
		--data-urlencode "client_secret=$client_secret" \
		--data-urlencode "refresh_token=$refresh_token" \
		--data-urlencode 'grant_type=refresh_token') || return

	now=$(date +%s)
	expires_at=$((now + $(jq -r '.expires_in // 3600' <<<"$response")))
	saved_token=$(jq -cn \
		--arg refresh_token "$refresh_token" \
		--argjson response "$response" \
		--argjson expires_at "$expires_at" \
		'$response + {refresh_token: $refresh_token, expires_at: $expires_at}')
	write_private_json "$token_file" "$saved_token" || return
	jq -r '.access_token' <<<"$response"
}

access_token() {
	local now cached_token cached_access_token cached_expiry client refresh_token

	now=$(date +%s)
	if [[ -r "$token_file" ]]; then
		cached_token=$(<"$token_file")
		cached_access_token=$(jq -r '.access_token // empty' <<<"$cached_token")
		cached_expiry=$(jq -r '.expires_at // 0' <<<"$cached_token")
		if [[ -n "$cached_access_token" && "$cached_expiry" =~ ^[0-9]+$ ]] && ((cached_expiry > now + 60)); then
			printf '%s\n' "$cached_access_token"
			return
		fi
	fi

	client=$(credentials) || return
	refresh_token=$(jq -r '.refresh_token // empty' "$token_file" 2>/dev/null)
	[[ -n "$refresh_token" ]] || {
		error "not authorized; run google-calendar.sh --authorize"
		return 1
	}
	refresh_access_token "$client" "$refresh_token"
}

calendar_events() {
	local time_min="$1"
	local end_of_day="$2"
	local token today now_epoch cached_response cached_day cached_at cached_time_min response

	today=$(TZ="$time_zone" date '+%F')
	now_epoch=$(date +%s)
	if [[ -r "$events_cache_file" ]]; then
		cached_response=$(<"$events_cache_file")
		cached_day=$(jq -r '.calendar_day // empty' <<<"$cached_response")
		cached_at=$(jq -r '.fetched_at // 0' <<<"$cached_response")
		cached_time_min=$(jq -r '.time_min // empty' <<<"$cached_response")
		if [[ "$cached_day" == "$today" && "$cached_time_min" == "$time_min" && "$cached_at" =~ ^[0-9]+$ ]] && ((now_epoch - cached_at < fetch_interval_seconds)); then
			jq -c '.response' <<<"$cached_response"
			return
		fi
	fi

	token=$(access_token) || return
	response=$(curl --fail-with-body --silent --show-error --get \
		--header "Authorization: Bearer $token" \
		--data-urlencode "timeMin=$time_min" \
		--data-urlencode "timeMax=$end_of_day" \
		--data-urlencode 'singleEvents=true' \
		--data-urlencode 'orderBy=startTime' \
		--data-urlencode 'maxResults=250' \
		--data-urlencode "timeZone=$time_zone" \
		'https://www.googleapis.com/calendar/v3/calendars/primary/events') || return
	write_private_json "$events_cache_file" "$(jq -cn \
		--arg calendar_day "$today" \
		--arg time_min "$time_min" \
		--argjson fetched_at "$now_epoch" \
		--argjson response "$response" \
		'{calendar_day: $calendar_day, time_min: $time_min, fetched_at: $fetched_at, response: $response}')" || return
	printf '%s\n' "$response"
}

shorten() {
	local text="$1"
	local limit="$2"

	if ((${#text} <= limit)); then
		printf '%s' "$text"
	elif ((limit <= 1)); then
		printf '…'
	else
		printf '%s…' "${text:0:limit - 1}"
	fi
}

render() {
	local now imminent_cutoff start_of_day end_of_day response simultaneous start start_epoch now_epoch display_time time_label remaining_minutes count title suffix prefix available text tooltip url class
	now=$(TZ="$time_zone" date --iso-8601=seconds)
	imminent_cutoff=$(TZ="$time_zone" date -d "$now + $imminent_interval_seconds seconds" --iso-8601=seconds)
	start_of_day=$(TZ="$time_zone" date -d 'today 00:00' --iso-8601=seconds)
	end_of_day=$(TZ="$time_zone" date -d 'tomorrow 00:00' --iso-8601=seconds)
	response=$(calendar_events "$start_of_day" "$end_of_day" 2>&1) || {
		emit '󰃭' "Google Calendar: $response" '["error"]'
		return
	}

	# The API response includes today's timed events. Prefer an imminent event,
	# then one in progress, then the next event. All-day events are ignored.
	simultaneous=$(jq -c --arg now "$now" --arg imminent_cutoff "$imminent_cutoff" '
		([.items[]? |
			select(.start.dateTime? and .end.dateTime? and .end.dateTime > $now) |
			select([.attendees[]? | select(.self == true) | .responseStatus] | index("declined") | not)
		] | sort_by(.start.dateTime)) as $events |
		if ($events | length) == 0 then []
		else ([ $events[] | select(.start.dateTime > $now and .start.dateTime < $imminent_cutoff) ] | sort_by(.start.dateTime)) as $imminent |
			([ $events[] | select(.start.dateTime <= $now) ] | sort_by(.start.dateTime)) as $ongoing |
			if ($imminent | length) > 0 then $imminent[0].start.dateTime
			elif ($ongoing | length) > 0 then $ongoing[0].start.dateTime
			else $events[0].start.dateTime end as $start |
			[$events[] | select(.start.dateTime == $start)] | sort_by((.summary // "") | ascii_downcase)
		end
	' <<<"$response") || {
		emit '󰃭' 'Google Calendar: invalid API response' '["error"]'
		return
	}

	count=$(jq 'length' <<<"$simultaneous")
	if ((count == 0)); then
		write_private_json "$event_file" '{"url":null}'
		emit '' 'No remaining timed events today' '["none"]'
		return
	fi

	start=$(jq -r '.[0].start.dateTime' <<<"$simultaneous")
	start_epoch=$(date -d "$start" +%s)
	now_epoch=$(date -d "$now" +%s)
	display_time=$(TZ="$time_zone" date -d "$start" '+%H:%M')
	title=$(jq -r '.[0].summary // "Untitled event"' <<<"$simultaneous")
	class='["upcoming"]'
	time_label="$display_time"
	if ((start_epoch <= now_epoch)); then
		time_label='Now'
	elif ((start_epoch - now_epoch <= imminent_interval_seconds)); then
		class='["upcoming", "imminent"]'
		if ((start_epoch - now_epoch < urgent_interval_seconds)); then
			class='["upcoming", "imminent", "urgent"]'
		fi
		remaining_minutes=$(((start_epoch - now_epoch + 59) / 60))
		time_label="${remaining_minutes}m"
	fi
	suffix=''
	if ((count > 1)); then
		suffix=" +$((count - 1))"
	fi
	prefix="󰃭 $time_label · "
	available=$((max_text_length - ${#prefix} - ${#suffix}))
	text="$prefix$(shorten "$title" "$available")$suffix"
	tooltip=$(jq -r '
		[.[] | "• \(.start.dateTime[11:16]) - \(.end.dateTime[11:16]) \(.summary // "Untitled event")"] | join("\n")
	' <<<"$simultaneous")
	url=$(jq -r '
		.[0] |
		([.conferenceData.entryPoints[]? | select(.entryPointType == "video") | .uri] | first) //
		.hangoutLink // .htmlLink // empty
	' <<<"$simultaneous")
	write_private_json "$event_file" "$(jq -cn --arg url "$url" '{url: $url}')"
	emit "$text" "$tooltip" "$class"
}

open_event() {
	local url
	[[ -r "$event_file" ]] || return
	url=$(jq -r '.url // empty' "$event_file")
	[[ -n "$url" ]] && xdg-open "$url" >/dev/null 2>&1 &
}

random_url_safe() {
	head -c "$1" /dev/urandom | base64 | tr '+/' '-_' | tr -d '=\n'
}

uri_encode() {
	jq -rn --arg value "$1" '$value | @uri'
}

query_value() {
	local query="$1"
	local wanted_key="$2"
	local pair key value
	local -a pairs

	IFS='&' read -r -a pairs <<<"$query"
	for pair in "${pairs[@]}"; do
		key=${pair%%=*}
		value=${pair#*=}
		if [[ "$key" == "$wanted_key" ]]; then
			value=${value//+/ }
			printf '%b' "${value//%/\\x}"
			return
		fi
	done
}

callback_handler() {
	local request_line header
	local callback_file="${WAYBAR_GOOGLE_CALENDAR_CALLBACK_FILE:?callback file is required}"

	IFS= read -r request_line || return 1
	printf '%s\n' "$request_line" >"$callback_file"
	while IFS= read -r header; do
		[[ -z "$header" || "$header" == $'\r' ]] && break
	done
	printf '%s\n' \
		'HTTP/1.1 200 OK' \
		'Content-Type: text/plain; charset=utf-8' \
		'Connection: close' \
		'' \
		'Authorization received. You can close this tab.'
}

authorize() {
	local client client_id client_secret auth_uri token_uri verifier challenge state redirect_uri authorization_url
	local request_file listener_pid request_line request_target query returned_state code response now expires_at token script_path

	client=$(credentials) || return
	client_id=$(jq -r '.client_id' <<<"$client")
	client_secret=$(jq -r '.client_secret' <<<"$client")
	auth_uri=$(jq -r '.auth_uri // "https://accounts.google.com/o/oauth2/auth"' <<<"$client")
	token_uri=$(jq -r '.token_uri // "https://oauth2.googleapis.com/token"' <<<"$client")
	verifier=$(random_url_safe 64)
	challenge=$(printf '%s' "$verifier" | sha256sum | awk '{print $1}' | xxd -r -p | base64 | tr '+/' '-_' | tr -d '=\n')
	state=$(random_url_safe 24)
	redirect_uri="http://127.0.0.1:$callback_port/oauth2callback"
	authorization_url="$auth_uri?client_id=$(uri_encode "$client_id")&redirect_uri=$(uri_encode "$redirect_uri")&response_type=code&scope=$(uri_encode "$scope")&access_type=offline&prompt=consent&state=$(uri_encode "$state")&code_challenge=$(uri_encode "$challenge")&code_challenge_method=S256"

	request_file=$(mktemp) || return
	script_path=$(readlink -f "$0")
	export WAYBAR_GOOGLE_CALENDAR_CALLBACK_FILE="$request_file"
	timeout 300 ncat --listen 127.0.0.1 "$callback_port" --sh-exec "$script_path --callback-handler" >/dev/null 2>&1 &
	listener_pid=$!

	printf '%s\n%s\n' 'Opening Google authorization in your browser…' "If it does not open, visit: $authorization_url" >&2
	xdg-open "$authorization_url" >/dev/null 2>&1 || true
	for _ in {1..300}; do
		if [[ -s "$request_file" ]]; then
			break
		fi
		sleep 1
	done
	kill "$listener_pid" 2>/dev/null || true

	request_line=$(head -n 1 "$request_file")
	rm -f "$request_file"
	request_target=${request_line#GET }
	request_target=${request_target%% HTTP/*}
	query=${request_target#*\?}
	returned_state=$(query_value "$query" state)
	code=$(query_value "$query" code)
	[[ "$returned_state" == "$state" && -n "$code" ]] || {
		error 'authorization was not completed within five minutes or state did not match'
		return 1
	}

	response=$(curl --fail-with-body --silent --show-error --request POST "$token_uri" \
		--data-urlencode "client_id=$client_id" \
		--data-urlencode "client_secret=$client_secret" \
		--data-urlencode "code=$code" \
		--data-urlencode "code_verifier=$verifier" \
		--data-urlencode 'grant_type=authorization_code' \
		--data-urlencode "redirect_uri=$redirect_uri") || return
	[[ $(jq -r '.refresh_token // empty' <<<"$response") ]] || {
		error 'Google did not return a refresh token'
		return 1
	}
	now=$(date +%s)
	expires_at=$((now + $(jq -r '.expires_in // 3600' <<<"$response")))
	token=$(jq -cn --argjson response "$response" --argjson expires_at "$expires_at" '$response + {expires_at: $expires_at}')
	write_private_json "$token_file" "$token" || return
	printf 'Authorized. Refresh token saved to %s\n' "$token_file"
}

main() {
	case "${1:-}" in
		--authorize) authorize ;;
		--open) open_event ;;
		--callback-handler) callback_handler ;;
		'') render ;;
		*) error "usage: ${0##*/} [--authorize|--open]"; return 2 ;;
	esac
}

main "$@"
