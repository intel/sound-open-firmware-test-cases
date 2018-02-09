# Check playback function
rm -rf playback.log
inputsample=48000
bit=dat
# Check passthrough Playback Pipeline
alsabat -D hw:0,0 -r $inputsample -c 2 -f $bit -F 1500
	if [ $? != 0 ]; then
		echo "Fail: playback failed with passthrough pipeline."
		echo "Check_passthrough_Pipeline_Playback_"$inputsample"_format_"$bit" FAIL" >> playback.log
		exit 1
	else
		echo "Check_passthrough_Pipeline_Playback_"$inputsample"_format_"$bit" PASS" >> playback.log
		echo "Check_passthrough_Pipeline_Capture_"$inputsample"_format_"$bit" PASS" >> playback.log
		exit 0
	fi
