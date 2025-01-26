#!/bin/bash

# Capture the list of upgraded packages
upgraded_packages=$(apt-get -s upgrade | grep '^Inst' | awk '{print $2}' | tr '[:upper:]' '[:lower:]' | sort | uniq)

# Check if there are upgraded packages
if [[ -n "$upgraded_packages" ]]; then
	#for USER_NAME in `users`
	for USER_NAME in `loginctl list-users --no-pager | awk '{ print $2 }' | tail -n +2 | grep -v '^$' | head -n -1`
	do
		#echo $USER_NAME
		USER_ID=`id -u $USER_NAME`
		#echo $USER_ID
		# enable notification with action for notify-send or dunstify
		if command -v notify-send >&2; then
			notification_cmd=/usr/bin/notify-send
			ACTION="default=System Update"
		else
			notification_cmd=/usr/bin/dunstify
			ACTION="default,System Update"
		fi
		#echo $ACTION
		RESULT=$(sudo -u $USER_NAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$USER_ID/bus $notification_cmd --action="$ACTION" "System Updates Available!!!" --icon=software-update-available -u critical)
		#echo $RESULT
		case "$RESULT" in
			"default")
				#echo "reply"
				sudo -u $USER_NAME DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$USER_ID/bus XDG_RUNTIME_DIR=/run/user/$USER_ID x-terminal-emulator -e bash -c "sudo apt-get clean all && sudo apt-get autoremove && sudo apt-get update && sudo apt-get dist-upgrade"
			;;
			"2")
				#echo "dismiss"
			;;
		esac
	done
fi
