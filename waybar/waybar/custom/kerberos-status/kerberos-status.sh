#!/usr/bin/env bash

# Reports the current Kerberos ticket state for Waybar.
if /usr/bin/klist -s >/dev/null 2>&1; then
  tickets=$(/usr/bin/klist)
  expires=$(awk '/krbtgt\// {print $3 " " $4; exit}' <<<"$tickets")
  renewable=$(awk '/^[[:space:]]*renew until / {print $3 " " $4; exit}' <<<"$tickets")

  expires_display=$(date -d "$expires" '+%d %b %H:%M' 2>/dev/null)
  renewable_display=$(date -d "$renewable" '+%d %b %H:%M' 2>/dev/null)

  if [[ -n "$expires_display" && -n "$renewable_display" ]]; then
    jq -cn \
      --arg tooltip "$(printf 'Valid until: %s\nRenewable until: %s' "$expires_display" "$renewable_display")" \
      '{text: "", class: "valid", alt: "valid", tooltip: $tooltip}'
  else
    printf '%s\n' '{"text":"","class":"valid","alt":"valid","tooltip":"Kerberos ticket valid"}'
  fi
else
  tickets=$(/usr/bin/klist 2>/dev/null || true)
  expires=$(awk '/krbtgt\// {print $3 " " $4; exit}' <<<"$tickets")
  expires_display=$(date -d "$expires" '+%d %b %H:%M' 2>/dev/null)

  if [[ -n "$expires_display" ]]; then
    jq -cn --arg tooltip "Expired at: $expires_display" \
      '{text: "", class: "expired", alt: "expired", tooltip: $tooltip}'
  else
    printf '%s\n' '{"text":"","class":"expired","alt":"expired","tooltip":"Kerberos ticket unavailable"}'
  fi
fi
