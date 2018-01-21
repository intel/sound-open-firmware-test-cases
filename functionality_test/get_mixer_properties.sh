#!/bin/bash

#Get mixer properties
amixer -D hw:bytcrrt5651 > /dev/null
if [ $? -ne 0 ]; then
	echo "get mixer properties failed"
	exit 1
else
	exit 0
fi
