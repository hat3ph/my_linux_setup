#!/bin/bash

# my custom dmenu power options
#echo -e "poweroff\nreboot\nsuspend" | $HOME/.local/bin/my_dmenu.sh -p "Power Options:" | xargs systemctl

choice=`echo -e "0: Logout\n1: Shutdown\n2: Reboot\n3: Suspend\n4: Cancel" | $HOME/.local/bin/my_dmenu.sh -p "Power Options:" | cut -d ':' -f 1`

# execute the choice in background
case "$choice" in
  #0) i3-msg exit & ;;
  #1) systemctl poweroff & ;;
  #2) systemctl suspend & ;;
  #3) systemctl reboot & ;;
  0) i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' \
    -B 'Exit' 'i3-msg exit' & ;;
  1) i3-nagbar -t warning -m 'You pressed the shutdown shortcut. Do you really want to shutdown your system? This will shutdown your system.' \
    -B 'Shutdown' 'systemctl poweroff' & ;;
  2) i3-nagbar -t warning -m 'You pressed the reboot shortcut. Do you really want to reboot your system? This will reboot your system.' \
    -B 'Reboot' 'systemctl reboot' & ;;
  3) i3-nagbar -t warning -m 'You pressed the suspend shortcut. Do you really want to suspend your system? This will suspend your system.' \
    -B 'Suspend' 'systemctl suspend' & ;;
  4) exit ;;
esac
