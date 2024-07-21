#!/bin/sh

# my custom dmenu_run setup
dmenu_path | $HOME/.config/i3/scripts/my_dmenu.sh "$@" | ${SHELL:-"/bin/sh"} &