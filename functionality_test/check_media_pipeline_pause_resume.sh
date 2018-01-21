# pause/resume test for media pipeline 

bit=S32_LE
# Check media Pipeline
alsabat -D hw:0,1 -c 2 -r 48000 -f $bit --interactive
if [ $? != 0 ]; then
	echo "Fail: pause/resume test failed with media pipeline ."
	exit 1
else
	echo "Pass: pause_resume test passed with media pipeline."
	exit 0
fi
