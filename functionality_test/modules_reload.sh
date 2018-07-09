#!/bin/bash

PLATFORM=$1

lsmod |egrep "snd|sof" > lsmod.list

SOF_MODULES=(sof_pci_dev sof_acpi_dev)
MACHINE_MODULES=(snd_soc_sst_bytcr_rt5640 snd_soc_sst_bytcr_rt5651 snd_soc_sst_cht_bsw_rt5645 snd_soc_sst_cht_bsw_rt5670 snd_soc_sst_byt_cht_da7213 snd_soc_sst_bxt_pcm512x snd_soc_cnl_rt274)
LOAD_MODULES=($(awk '{print $1}' lsmod.list))

ERR_COUNT_BEFORE=`dmesg | grep sof-audio | grep "error" | wc -l`

# unload audio modules
remove()
{

	for i in ${SOF_MODULES[@]}
	do
		for j in ${LOAD_MODULES[@]}
			do
				if [ $i == $j ]; then
					echo $i
					modprobe -r $i
				fi
		done
	done

	for i in ${MACHINE_MODULES[@]}
	do
		for j in ${LOAD_MODULES[@]}
			do
				if [ $i == $j ]; then
					echo $i
					modprobe -r $i
				fi
		done
	done
}

err_check()
{
	ERR_COUNT_AFTER=`dmesg | grep sof-audio | grep "error" | wc -l`
	if [ $ERR_COUNT_AFTER -gt $ERR_COUNT_BEFORE ]
	then
		exit 1
	else
		exit 0
	fi
}

# reload audio modules
reload()
{
	if [ $PLATFORM == 'byt' ]; then
		modprobe sof_acpi_dev
		sleep 2
		err_check
	elif [ $PLATFORM == 'apl' ] || [ $PLATFORM == 'cnl' ]; then
		modprobe sof_pci_dev
		sleep 2
		err_check
	else
		echo "no matched platform, please confirm it"
		exit 1
	fi
}

remove
sleep 2
reload
