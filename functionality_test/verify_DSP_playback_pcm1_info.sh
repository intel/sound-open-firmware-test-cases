#!/bin/bash

#diff test_scripts/pcm1pinfo /proc/asound/card0/pcm1p/info > /tmp/plk0infdiff.log
cat  /proc/asound/bytrt5651/pcm1p/info > /dev/null
if [ $? -ne 0 ]; then
        echo "Fail: DSP PCM1 info doesnot match"
#        echo "The diff is:"
#        cat /tmp/plk0infdiff.log | while read line
#        do
#                echo $line
#        done
        exit 1
else
        exit 0
fi

