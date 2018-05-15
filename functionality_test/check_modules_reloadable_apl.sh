#!/bin/bash

# unload audio modules
while read line
do
	rmmod $line
	if [ $? != 0 ]; then
		echo "modules unload failed: $line"
		return 1
	fi
done < apl/apl.modules

sleep 2
# reload modules
modprobe sof_pci_dev
if [ $? != 0 ]; then
	echo "modules reload failed"
	exit 1
else
	echo "modules reload passed"
fi

