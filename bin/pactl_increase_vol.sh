#!/bin/bash

# prevent pulseaudio increase volume more than 100%
max_vol=100
current_vol=$(pactl list sinks | grep Volume | head -n1 | awk '{print $5}' | sed 's/\%//g')
if [[ $current_vol -lt $max_vol ]]; then pactl set-sink-volume @DEFAULT_SINK@ $1; fi