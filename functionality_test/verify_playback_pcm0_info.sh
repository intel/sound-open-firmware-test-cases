#!/bin/bash

#diff test_scripts/pcm0pinfo /proc/asound/card0/pcm0p/info > /tmp/plk0infdiff.log
cat  /proc/asound/sofbytcrrt5651/pcm0p/info |grep PLAYBACK > /dev/null
if [ $? -ne 0 ]; then
        echo "Fail: DSP PCM0 info doesnot match"
#        echo "The diff is:"
#        cat /tmp/plk0infdiff.log | while read line
#        do
#                echo $line
#        done
        exit 1
else
        exit 0
fi

