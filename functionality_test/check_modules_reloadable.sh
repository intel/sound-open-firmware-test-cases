# reload the audio modules
arecord -l |grep "device"
if [ $? != 0 ]; then
        exit 1
else
        exit 0
fi

sleep 2
 
#check modules are reloaded
aplay -l |grep "device"
if [ $? != 0 ]; then
	exit 1
else
	exit 0
fi

sleep 2
