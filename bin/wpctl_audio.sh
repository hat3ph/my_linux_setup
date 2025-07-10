#!/bin/bash

audio_level=5
notification_interval=3000

# use notify-send from libnotify-bin package or dunstify from dunst package
if command -v notify-send >&2; then
	notification_cmd=/usr/bin/notify-send
else
	notification_cmd=/usr/bin/dunstify
fi

function send_notification() {
	volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | cut -d ' ' -f 2 | awk '{printf "%2.0f%%\n", 100 * $1}')
	$notification_cmd -t $notification_interval -i audio-speakers -u low -r "9993" -h int:value:"$volume" "Audio Level $volume"
}

case $1 in
status)
	send_notification
	;;
up)
	# increase audio level and send notification
	wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ $audio_level%+
	send_notification
	;;
down)
	# decrease audio level and send notification
	wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ $audio_level%-
	send_notification
	;;
mute)
	# toggle audio to mute or unmute
	wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
	# send audio muted notification if muted or send audio level notification if not muted
	if [[ -n $(wpctl get-volume @DEFAULT_AUDIO_SINK@ | cut -d ' ' -f 3 | sed 's/^.//;s/.$//') ]]; then
		$notification_cmd -t $notification_interval -i audio-volume-muted "Audio Muted"
	else
		send_notification
	fi
	;;
mic)
	# toggle microphone to mute or un-mute
	wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
	# send notification if microphone is muted or un-muted
	if [[ -n $(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | cut -d ' ' -f 3 | sed 's/^.//;s/.$//') ]]; then
		$notification_cmd -t $notification_interval -i audio-input-microphone-muted "Microphone Muted"
	else
		$notification_cmd -t $notification_interval -i audio-input-microphone "Microphone Un-Muted"
	fi
	;;
*)
	echo "Usage: $0 {status|up|down|mute|mic}"
	exit 1
	;;
esac
