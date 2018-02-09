# make sure machine deriver is not in use
mv /usr/bin/pulseaudio /usr/bin/pulseaudio-bak
sleep 1

pkill -9 pulseaudio
sleep 2

#unload audio modules
rmmod snd_soc_sst_bytcr_rt5651
rmmod snd_soc_rt5651
rmmod snd_soc_rt5651
rmmod sof_acpi_dev
rmmod snd_soc_acpi
rmmod snd_sof_intel_byt
rmmod snd_sof
rmmod snd_soc_acpi_intel_match
rmmod snd_soc_acpi

#check modules are unloaded
(aplay -l) >& list.log
cat list.log |grep "no soundcards found" > /dev/null
if [ $? != 0 ]; then
	exit 1
else
	exit 0
fi

