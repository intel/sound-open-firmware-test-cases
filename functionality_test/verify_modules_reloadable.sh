# set the criterion time for modules reloading
criterion_time=50

#unload audio modules
rmmod sof_acpi_dev
#rmmod snd_sof_nocodec
#rmmod snd_sof_intel_hsw
#rmmod snd_sof_intel_bdw
rmmod snd_sof_intel_byt
rmmod snd_sof

#check modules are unloaded
aplay -l
if [ $? == 0 ]; then
    echo "Fail: failed to unload modules."
    echo "unload_audio_modules FAIL" >> playback.log
else
    echo "unload_audio_modules PASS" >> playback.log
fi

# reloading the audio modules
modprobe sof_acpi_dev >& rl_time.log
reload_time=`cat rl_time |grep "real" | awk -F '.' '{print $2}' |cut -c1-3`
if [ $reload_time -gt $criterion_time ]; then
		echo "Fail: audio modules reloading time to long: $reload_time"
		echo "modules_reloading_time FAIL" >> playback.log
else 
	echo "modules_reloading_time Pass" >> playback.log
fi

#check modules are reloaded
aplay -l
if [ $? != 0 ]; then
	echo "Fail: failed to reload modules."
	echo "reload_audio_modules FAIL" >> playback.log
else
    echo "reload_audio_modules PASS" >> playback.log
fi
#check playback after modules reloaded
alsabat -D hw:0,0 -r 48000 -c 1 -f S32_LE
if [ $? != 0 ]; then
	echo "Fail: playback failed after modules reloaded."
	echo "Check_Low_Latency_Pipeline_Playback_after_modules_reloaded FAIL" >> playback.log
else
	echo "Check_Low_latency_Pipeline_Playback_after_modules_reloaded PASS" >> playback.log
fi

