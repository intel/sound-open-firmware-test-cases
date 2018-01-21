#!/bin/sh

# Verify DSP firmware is presence
ls /lib/firmware/intel/reef-byt.ri > /dev/null
if [ $? != 0 ]; then
	echo "Fail: DSP firmware doesnot presence."
	exit 1
else 
        exit 0
fi
