# channel test for low latency 
rm -rf playback.log

input_freq=1500
bit=dat
# Check Media Playback Pipeline
alsabat -D hw:0,0 -c 1 -F $input_freq -f $bit -r 48000
if [ $? != 0 ]; then
	echo "Fail: channel test failed with passthrough pipeline ."
	echo "channel_test_with_passthrough pipeline_mono_stream FAIL" >> playback.log
else
	echo "channel_test_with_passthrough_pipeline_mono_stream PASS" >> playback.log
fi

# media pipeline check
frequency_L=1500
frequency_R=1500
bit=dat
# Check Media Playback Pipeline
alsabat -D hw:0,0 -r 48000 -c 2 -F $frequency_L:$frequency_R -f $bit
if [ $? != 0 ]; then
	echo "Fail: channel test failed with passthrough pipeline ."
	echo "channel_test_with_passthrough_stereo_stream FAIL" >> playback.log
else
	echo "channel_test_with_passthrough_stereo_stream PASS" >> playback.log
fi

