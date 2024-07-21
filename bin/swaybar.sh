#!/bin/bash

# custom emoji
cpu_emoji=
mem_emoji=

# output current date
#date_formatted=$(date "+%a %F %H:%M"%p)
date_formatted=$(date "+%R%p")
case $(date +%H) in
	00 | 01 | 02 | 03 | 04 | 05)
		date_emoji= # 🌜
	;;
	06 | 07 | 08 | 09 | 10 | 11)
		date_emoji= # ☀️
	;;
	12 | 13 | 14 | 15 | 16 | 17)
		date_emoji= # 🥪
	;;
	18 | 19 | 20 | 21)
		date_emoji= # 🍽️
	;;
	22 | 23 | 24)
		date_emoji= # 🌜
	;;
esac

# check pipewire audio mic/volume level and status via wireplumber or pulseaudio-utils
if [[ ! $(command -v pactl) ]]; then
	if [[ -n $(wpctl get-volume @DEFAULT_AUDIO_SINK@ | cut -d ' ' -f 3 | sed 's/^.//;s/.$//') ]]; then
		volume_emoji= # 🔇
		volume_level="MUTED"
	else
		volume_emoji= # 🔊
		volume_level=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | cut -d ' ' -f 2 | awk '{printf "%2.0f%%\n", 100 * $1}')
	fi
	if [[ -n $(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | cut -d ' ' -f 3 | sed 's/^.//;s/.$//') ]]; then
		mic_emoji=
		mic_level="MUTED"
	else
		mic_emoji=
		mic_level=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | cut -d ' ' -f 2 | awk '{printf "%2.0f%%\n", 100 * $1}')
	fi
else
	if [[ $(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}') == "yes" ]]; then
		volume_emoji= # 🔇
		volume_level="MUTED"
	else
		volume_emoji= # 🔊
		volume_level=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}')
	fi
	if [[ $(pactl get-source-mute @DEFAULT_SOURCE@ | awk '{print $2}') == "yes" ]]; then
		mic_emoji=
		mic_level="MUTED"
	else
		mic_emoji=
		mic_level=$(pactl get-source-volume @DEFAULT_SOURCE@ | awk '{print $5}')
	fi
fi

# check total cpu usage and temp
cpu_usage="$[100-$(vmstat 1 2|tail -1|awk '{print $15}')]"%
cpu_temp=$(cat /sys/class/thermal/thermal_zone0/temp)
#cpu_temp=$(cat /sys/class/hwmon/hwmon3/temp1_input)
cpu_temp=$(($cpu_temp/1000))°C

# check total memory usage
#mem_usage="$(free | grep Mem | awk '{printf "%2.0f%%\n", $3/$2 * 100}')"
mem_usage="$(free -h | awk 'NR==2 {print $3}')"

# check network connection ⛔🛜
#net_info="$(ip -o route get to 8.8.8.8 | sed -n 's/.*src \([0-9.]\+\).*/\1/p') ($(ip -o route get to 8.8.8.8 | awk '{print $5}'))"
ping -q -w 1 -c 1 `ip r | grep default | grep -v linkdown | cut -d ' ' -f 3` > /dev/null && \
	net_info="$(ip -o route get to 8.8.8.8 | sed -n 's/.*src \([0-9.]\+\).*/\1/p') ($(ip -o route get to 8.8.8.8 | awk '{print $5}'))" net_emoji= \
	|| net_info="Disconnected" net_emoji=

# Returns the battery status: "Full", "Discharging", or "Charging" if available.
if [[ -d /sys/class/power_supply/BAT0 ]]; then
	battery_status=$(cat /sys/class/power_supply/BAT0/status)
	battery_capacity=$(cat /sys/class/power_supply/BAT0/capacity)%
	if [[ $battery_status == "Full" ]]; then
		battery_emoji= # 🔌
	elif [[ $battery_status == "Discharging" ]]; then
		if [[ $battery_capacity -lt 20 ]]; then notify-send -u critical "Battery capacity less than 20%"; fi
		battery_emoji= # 🪫
	else
		battery_emoji= # 🔋
	fi
fi

# add weather support, choose format 1 or 3
weather=`curl wttr.in/Ipoh?format=1`

# output to swaybar
echo $cpu_emoji $cpu_usage $cpu_temp $mem_emoji $mem_usage $net_emoji $net_info $battery_emoji $battery_status $battery_capacity \
		$mic_emoji $mic_level $volume_emoji $volume_level $date_emoji $date_formatted