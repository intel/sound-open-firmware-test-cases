#!/bin/sh

# check_playback_hardware_device
for i in 0 1
   do 
   aplay -l | grep -c "device $i" >/dev/null
   if [ $? != 0 ]; then
	echo "Fail: Can't found playback hardware device."
	exit 1
  fi
done
exit 0
