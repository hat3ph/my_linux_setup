#!/bin/bash

# enable firefox wayland protocol
export MOZ_ENABLE_WAYLAND=1

# set sway as default desktop session
export XDG_SESSION_DESKTOP=sway
export XDG_CURRENT_DESKTOP=sway

# fix missing mouse cursors with specific hardware
#export WLR_NO_HARDWARE_CURSORS=1

# allow wayland QT theme
export QT_QPA_PLATFORMTHEME=qt5ct
export QT_QPA_PLATFORM=wayland

# set XDG global env
export XDG_CACHE_HOME=$HOME/.cache
export XDG_CONFIG_HOME=$HOME/.config
export XDG_DATA_HOME=$HOME/.local/share
export XDG_STATE_HOME=$HOME/.local/state

# start sway
exec sway