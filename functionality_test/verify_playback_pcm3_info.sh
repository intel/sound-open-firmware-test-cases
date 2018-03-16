#!/bin/bash

cat /proc/asound/sofbytrt5651/pcm3p/info > /dev/null
if [ $? -ne 0 ]; then
        echo "Fail: DSP PCM3 info doesnot match"
        exit 1
else
        exit 0
fi

