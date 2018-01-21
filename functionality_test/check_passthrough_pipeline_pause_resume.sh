# pause/resume test for passthrough pipeline 

bit=dat
# Check passthrough Pipeline
alsabat -D hw:0,0 -c 2 -r 48000 -f $bit
if [ $? != 0 ]; then
	echo "Fail: pause/resume test failed with passthrough pipeline ."
	exit 1
else
	echo "Pass: pause_resume test passed with passthrough pipeline."
	exit 0
fi
