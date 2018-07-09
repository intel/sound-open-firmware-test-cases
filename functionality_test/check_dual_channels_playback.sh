# Check two channel playabck function
rm -rf playback.log
RATE=$1
if [ $RATE == "48k" ]; then
	RATE=48000
fi
FORMAT=$2
if [ $FORMAT == "s16le" ]; then
	FORMAT=dat
elif [ $FORMAT == "s24le" ]; then
	FORMAT=S24_3LE
elif [ $FORMAT == "s32le" ]; then
	FORMAT=S32_LE
fi

PIPELINE_TYPE=$3
PLATFORM=$4

# amixer setting for line in/out mode 
alsactl restore -f asound_state/$PLATFORM/asound.state.line
sleep 2
alsabat -D hw:0,0 -r $RATE -c 2 -f $FORMAT -F 1500
	if [ $? != 0 ]; then
		echo "Fail: dual channels playback test failed."
		echo "Check_"$PIPELINE_TYPE"_dual_channels_"$RATE"_"$FORMAT"_playback FAIL" >> playback.log
		exit 1
	else
		echo "Check_"$PIPELINE_TYPE"_dual_channels_"$RATE"_"$FORMAT"_playback PASS" >> playback.log
		exit 0
	fi
