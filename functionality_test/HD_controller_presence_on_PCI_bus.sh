#!/bin/sh

# Check the Audio PCI ID on PCI bus
lspci | grep "Audio device" > /dev/null
if [ $? != 0 ]; then
	echo "Fail: Can not get Audio HD controller on PCI bus"
	exit 1
     else 
        exit 0
fi
