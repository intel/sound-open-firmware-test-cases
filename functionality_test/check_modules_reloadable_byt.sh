#!/bin/bash

# unload audio modules
while read line
do
	rmmod $line
	if [ $? != 0 ]; then
		echo "modules unload failed: $line"
		return 1
	fi
done < byt/byt.modules

sleep 2
# reload modules
modprobe sof_acpi_dev
if [ $? != 0 ]; then
	echo "modules reload failed"
	return 1
else
	echo "modules reload passed"
fi

