#unload audio modules
rmmod sof_acpi_dev
#rmmod snd_sof_nocodec
#rmmod snd_sof_intel_hsw
#rmmod snd_sof_intel_bdw
rmmod snd_sof_intel_byt
rmmod snd_sof

#check modules are unloaded
(aplay -l) >& list.log
cat list.log |grep "no soundcards found" > /dev/null
if [ $? != 0 ]; then
	exit 1
else
	exit 0
fi

