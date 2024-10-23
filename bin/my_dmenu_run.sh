#!/bin/sh

# my custom dmenu_run setup
dmenu_path | $HOME/.local/bin/my_dmenu.sh "$@" | ${SHELL:-"/bin/sh"} &
