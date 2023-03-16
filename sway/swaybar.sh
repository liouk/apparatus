# date/time
cur_date=$(date '+%a %-d/%-m')
cur_time=$(date '+%H:%M')

# keyboard layout
kb_layout=$(swaymsg -t get_inputs -r | grep -m1 xkb_active_layout_name | cut -d'"' -f4)
kb_layout=${kb_layout:0:2}
kb_layout=${kb_layout,,}

# battery
battery_charge=$(upower --show-info $(upower --enumerate | grep 'BAT') | egrep "percentage" | awk '{print $2}')
battery_status=$(upower --show-info $(upower --enumerate | grep 'BAT') | egrep "state" | awk '{print $2}')
if [ $battery_status = "discharging" ]; then
    battery_icon='󰂀'
else
    battery_icon=''
fi

# audio & media
volctl="$HOME/.config/sway/volctl.sh"
audio_volume=$(eval "$volctl get-vol")
audio_is_muted=$(eval "$volctl get-mute")
media_artist=$(playerctl metadata artist)
media_song=$(playerctl metadata title)
player_status=$(playerctl status)

if [ -n "$media_artist" ]; then
  media_artist="$media_artist - "
fi

s="‖"
song_status=""
case $player_status in
  Playing)
    song_status=" $media_artist$media_song $s ";;
  Paused)
    song_status=" $media_artist$media_song $s ";;
esac

if [ $audio_is_muted = "yes" ]; then
    audio_icon="󰖁"
else
    audio_icon=""
fi

# weather
# curl -Ss 'https://wttr.in/Zurich,%20Switzerland?0&T&Q&format=1'

printf "%s%s %s $s %s %s $s  %s $s  %s  %s" \
  "$song_status" "$audio_icon" "$audio_volume" \
  "$battery_icon" "$battery_charge" \
  "$kb_layout" \
  "$cur_date" "$cur_time"
