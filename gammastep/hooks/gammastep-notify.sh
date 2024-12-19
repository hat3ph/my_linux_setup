#!/bin/bash

# use notify-send from libnotify-bin package or dunstify from dunst package
if command -v notify-send >&2; then
	notification_cmd=/usr/bin/notify-send
else
	notification_cmd=/usr/bin/dunstify
fi

case $1 in
    period-changed)
        $notification_cmd "Gammastep Period changed to $3"
esac