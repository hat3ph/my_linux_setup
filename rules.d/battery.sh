#!/bin/bash

brightness_level=10
notification_interval=3000
brightness=$(brightnessctl info | cut -d ' ' -f 4 | grep -oP '\(\K[^%)]+')

# use notify-send from libnotify-bin package or dunstify from dunst package
if command -v notify-send >&2; then
	notification_cmd=notify-send
else
	notification_cmd=dunstify
fi

function send_notification() {
	$notification_cmd -t $notification_interval -i audio-speakers -u low -r "9994" -h int:value:"$brightness" "Brightness Level $brightness"
}

case $1 in
up)
	# increase screen brightness level and send notification
	brightnessctl set 100%
	#send_notification $1
	;;
down)
	# decrease audio level and send notification
	brightnessctl set 50%
	#send_notification $1
	;;
esac
