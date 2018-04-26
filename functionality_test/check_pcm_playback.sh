# Check playback function
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

# Check passthrough Playback Pipeline
alsabat -D hw:0,0 -r $RATE -c 2 -f $FORMAT -F 1500
	if [ $? != 0 ]; then
		echo "Fail: playback failed with "$PIPELINE_TYPE" pipeline."
		echo "Check_"$PIPELINE_TYPE"_Playback_"$RATE"_format_"$FORMAT" FAIL" >> playback.log
		exit 1
	else
		echo "Check_"$PIPELINE_TYPE"_Playback_"$RATE"_format_"$FORMAT" PASS" >> playback.log
		echo "Check_"$PIPELINE_TYPE"_Capture_"$RATE"_format_"$FORMAT" PASS" >> playback.log
		exit 0
	fi
