#!/bin/bash

# capture full or region screenshot to clipboard
# require grim, slurp and wl-clipboard packages

# create screenshots directory if not available
SCREENSHOT_DIR="${HOME}/Pictures/screenshots"
if [[ ! -d $SCREENSHOT_DIR ]]; then mkdir -p $SCREENSHOT_DIR; fi

# use notify-send from libnotify-bin package or dunstify from dunst package
if command -v notify-send >&2; then
	notification_cmd=/usr/bin/notify-send
else
	notification_cmd=/usr/bin/dunstify
fi

case $1 in
region)
	grim -g "$(slurp)" - | wl-copy
	$notification_cmd -u low "Screenshot save to clipboard!"
	;;
full)
	grim - | wl-copy
	$notification_cmd -u low "Screenshot save to clipboard!"
	;;
region-save)
	grim -g "$(slurp)" $SCREENSHOT_DIR/screenshot_$(date +%Y_%m_%d_%H_%M_%S).png
	$notification_cmd -u low "Screenshot save to $SCREENSHOT_DIR!"
	;;
full-save)
	grim $SCREENSHOT_DIR/screenshot_$(date +%Y_%m_%d_%H_%M_%S).png
	$notification_cmd -u low "Screenshot save to $SCREENSHOT_DIR!"
	;;
*)
	echo "Purpose: Capture/save/display screenshots with grim, slurp and wl-clipboard packages in wayland!"
    echo "Syntax: $SCRIPT [option]"
    echo "options:"
    echo "region           Select area"
    echo "regiion-save     Select are and save to folder"
    echo "full             Current window"
    echo "full-save        Save current window to folder"
    echo ""
    echo ""
	;;
esac

