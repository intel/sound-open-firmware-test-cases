# Check two channel playabck function
rm -rf playback.log
RATE=$1
if [ $RATE == "48K" ]; then
	RATE=48000
fi
FORMAT=$2
if [ $FORMAT == "s16le" ]; then
	FORMAT=dat
elif [ $FORMAT == "s24le" ]; then
	FORMAT=S24_LE
elif [ $FORMAT == "s32le" ]; then
	FORMAT=S32_LE
fi

PIPELINE_TYPE=$3
PLATFORM=$4

# amixer setting for line in/out mode 
alsactl restore -f asound_state/$PLATFORM/asound.state.line
sleep 2
alsabat -D hw:0,0 -r $RATE -c 1 -f $FORMAT -F 1500
	if [ $? != 0 ]; then
		echo "Fail: single channels playback test failed."
		echo "Check_single_channel_"$PIPELINE_TYPE"_"$RATE"_"$FORMAT"_playback FAIL" >> playback.log
		exit 1
	else
		echo "Check_single_channel_"$PIPELINE_TYPE"_"$RATE"_"$FORMAT"_playback PASS" >> playback.log
		exit 0
	fi
