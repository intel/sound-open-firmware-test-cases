#!/bin/sh

# Check the Audio PCI ID on PCI bus
lspci | grep -i audio | grep 00:1b.0 > /dev/null
if [ $? != 0 ]; then
        echo "Fail: Can not get Audio device"
        exit 1
     else
        exit 0
fi

