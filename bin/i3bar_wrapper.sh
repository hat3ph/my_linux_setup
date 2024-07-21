#!/bin/bash

# optional i3status output wrapper for external script
# credit: https://en.jeffprod.com/blog/2020/create-your-own-i3-sway-status-bar/
time=1

# Send the header so that i3bar knows we want to use JSON:
echo '{ "version": 1 }'

# Begin the endless array.
echo '['

# We send an empty first array of blocks to make the loop simpler:
echo '[]'

# Now send blocks with information forever:
while :;
do
  echo ",[{\"name\":\"id_bar\",\"full_text\":\"$($1)\"}]"
  sleep $time
done