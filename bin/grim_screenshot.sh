#!/bin/bash

# capture full or region screenshot
# require grim, slurp and wl-clipboard packages

case $1 in
region)
	grim -g "$(slurp)" - | wl-copy
	;;
full)
	grim - | wl-copy
	;;
esac
