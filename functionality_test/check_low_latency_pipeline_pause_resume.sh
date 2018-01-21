# pause/resume test for low latency 

bit=S32_LE
# Check low latency Pipeline
alsabat -D hw:0,0 -c 2 -r 48000 -f $bit --interactive
if [ $? != 0 ]; then
	echo "Fail: pause/resume test failed with low latency pipeline ."
	exit 1
else
	echo "Pass: pause_resume test passed with low latency pipeline."
	exit 0
fi
