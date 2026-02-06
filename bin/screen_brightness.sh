#!/bin/bash

brightness_level=10
notification_interval=3000
app=brightnessctl

# use notify-send from libnotify-bin package or dunstify from dunst package
if command -v notify-send &> /dev/null; then
	notification_cmd=/usr/bin/notify-send
else
	notification_cmd=/usr/bin/dunstify
fi

# check application availability
if ! command -v $app &> /dev/null; then
	$notification_cmd -t $notification_interval -i display-brightness -u critical "Missing $app application!!!"
	exit 1
fi

function send_notification() {
	brightness=$(brightnessctl info | cut -d ' ' -f 4 | grep -oP '\(\K[^%)]+')
	$notification_cmd -t $notification_interval -i display-brightness -u low -r "9994" -h int:value:"$brightness" "Brightness Level $brightness%"
}

case $1 in
up)
	# increase screen brightness level and send notification
	$app set $brightness_level%+
	send_notification
	;;
down)
	# decrease screen brightness level not more then 50% and send notification
	if [ "$brightness" -gt 50 ]; then
		$app set $brightness_level%-
	fi
	send_notification
	;;
*)
	echo "Usage: $0 {up|down}"
	exit 1
	;;
esac
