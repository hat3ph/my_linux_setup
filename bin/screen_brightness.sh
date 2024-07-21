#!/bin/bash

brightness_level=10
notification_interval=3000
brightness=$(brightnessctl info | cut -d ' ' -f 4 | grep -oP '\(\K[^%)]+')

# use notify-send from libnotify-bin package or dunstify from dunst package
if command -v notify-send >&2; then
	notification_cmd=/usr/bin/notify-send
else
	notification_cmd=/usr/bin/dunstify
fi

function send_notification() {
	$notification_cmd -t $notification_interval -i audio-speakers -u low -r "9994" -h int:value:"$brightness" "Brightness Level $brightness%"
}

case $1 in
up)
	# increase screen brightness level and send notification
	brightnessctl set $brightness_level%+
	send_notification $1
	;;
down)
	# decrease screen brightness level not more then 50% and send notification
	if [ "$brightness" -gt 50 ]; then
		brightnessctl set $brightness_level%-
	fi
	send_notification $1
	;;
*)
	echo "Usage: $0 {up|down}"
	exit 1
	;;
esac
