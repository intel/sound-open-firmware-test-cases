# Check playback function
/usr/bin/pulseaudio --start
if [ $? != 0 ]; then
	echo "Fail: start pulseaudio server failed"
	echo "start pulseaudio server: FAIL" >> playback.log
else 
	echo "Pass: start pulseaudio server passed"
fi
sleep 2

rm -rf playback.log
#inputsample=(8000 11025 12000 16000 18900 22050 24000 32000 44100 48000 64000 88200 96000 176400 192000)
inputsample=(8000, 16000, 24000, 32000, 44100, 48000)
bitlist=dat
# Check Media Playback Pipeline
for samplerate in ${inputsample[*]};do
	sleep 2
	alsabat -Ppulse hw:0,0  -r $samplerate -c 2 -f $bitlist -F 1500
		if [ $? != 0 ]; then
			echo "Fail: pulseaudio playback failed with passthrough pipeline."
			echo "Check_pulseaudio_Playback_"$samplerate"_Bit_"$bit" FAIL" >> playback.log
		else
			echo "Check_pulseaudio_Playback_"$samplerate"_Bit_"$bit" PASS" >> playback.log
		fi
done
