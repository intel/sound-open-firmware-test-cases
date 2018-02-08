# Check line in/out function
rm -rf playback.log
inputsample=48000
bit=dat

# amixer setting for line in/out mode 
alsactl restore -f asound_state/asound.state.line
sleep 2
alsabat -D hw:0,0 -r $inputsample -c 2 -f $bit -F 1500
	if [ $? != 0 ]; then
		echo "Fail: line in/out mode playback test failed."
		echo "Check_line_in_out_playback FAIL" >> playback.log
		exit 1
	else
		echo "Check_line_in_out_playback PASS" >> playback.log
		exit 0
	fi
