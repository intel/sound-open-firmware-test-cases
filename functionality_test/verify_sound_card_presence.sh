#!/bin/sh

# Verify sound card presence
aplay -l |grep "card 0:" > /dev/null
if [ $? != 0 ]; then
	echo "Fail: Can't get sound card presence."
	exit 1
else
        exit 0
fi
