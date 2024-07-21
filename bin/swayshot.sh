#!/usr/bin/env bash
# Purpose: Capture/save/display screenshots within sway window manager
# Author : Daniel Wayne Armstrong <hello@dwarmstrong.org>

# Requires:
# * grimshot <https://github.com/swaywm/sway/blob/master/contrib/grimshot>
# * gthumb <https://gitlab.gnome.org/GNOME/gthumb>
# * sway <https://github.com/swaywm/sway>

set -euo pipefail

SCRIPT=$(basename $0)
TARGET="active"
SCREENSHOT_DIR="${HOME}/Pictures"
IMAGE="${SCREENSHOT_DIR}/screenshot_$(date +%FT%H%M%S).png"

if [[ ! -d $SCREENSHOT_DIR ]]; then mkdir -p $SCREENSHOT_DIR; fi

Help() {
    echo "Purpose: Capture/save/display screenshots within sway window manager"
    echo "Syntax: $SCRIPT [option]"
    echo "options:"
    echo "-h     Print this help"
    echo "-a     Select area"
    echo "-o     Current output"
    echo "-w     Current window"
    echo ""
    echo ""
}


run_options() {
    while getopts ":haow" OPT; do
        case $OPT in
            h)  Help
                exit;;
            a)  TARGET="area"
                ;;
            o)  TARGET="output"
                ;;
            w)  TARGET="active"
                ;;
            \?) echo "error: Invalid option"
                exit;;
        esac
    done
}


run_options "$@"
grimshot save $TARGET $IMAGE
xdg-open $IMAGE