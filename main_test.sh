#!/bin/bash

CURRENT_PATH=`pwd`
FEATURE_PASS=0
FEATURE_CNT=0
TEST_TYPE="functionality_test"
FIRMWARE_PATH="/lib/firmware/intel"
DATE=`date +%Y_%m_%d_%H_%M`

# default tplg

SSP=ssp2
MODE=I2S
PIPELINE=volume
FORMAT_INPUT=s16le
FORMAT_OUTPUT=s16le
RATE=48k
MCLK=19200k
CODEC=codec
para=$1

switch_tplg() {

	# get next tplg name
	tplg_next=$(($tplg_num + 1))
	if [ $tplg_next -gt $tplg_max ]; then
		echo "Done the test for all supported topologies"
		echo "done" > $TEST_STATUS/test_status
		exit 0
	fi

	tplg_name=`sed -n ${tplg_next}p ./$PLATFORM/$MACHINE/tplg`
	echo "continue" > $TEST_STATUS/test_status
	echo $tplg_next > $TEST_STATUS/tplg

	# relink the tplg
	if [ $PLATFORM == "byt" -a $MACHINE == "minnow" ]; then
		sudo ln -fs $FIRMWARE_PATH/topology/$tplg_name $FIRMWARE_PATH/sof-$PLATFORM-rt5651.tplg
	elif [ $PLATFORM == "apl" -a $MACHINE == "gp" ]; then
		sudo ln -fs $FIRMWARE_PATH/topology/$tplg_name $FIRMWARE_PATH/sof-$PLATFORM-nocodec.tplg
	elif [ $PLATFORM == "apl" -a  $MACHINE == "up" ]; then
		sudo ln -fs $FIRMWARE_PATH/topology/$tplg_name $FIRMWARE_PATH/sof-$PLATFORM-nocodec.tplg
	else
		sudo ln -fs $FIRMWARE_PATH/topology/$tplg_name $FIRMWARE_PATH/sof-$PLATFORM.tplg
	fi
	# system will auto reboot for another tplg test
	sleep 2
	sudo reboot
}

feature_test_list() {
	tplg_file=`find $FIRMWARE_PATH -name "sof-*.tplg"`
	link_path=`readlink $tplg_file`
	link_file=${link_path##*/}

	echo "now is testing $link_file" >> $CURRENT_PATH/$test_report
	while read line
	do
		feature_test $line
	done < ./$PLATFORM/$MACHINE/feature-test
	switch_tplg
}

run_test() {
	#get tplg
	tplg_num=`cat $TEST_STATUS/tplg |awk -F ' ' '{print $1}'`
	tplg_name=`sed -n ${tplg_num}p ./$PLATFORM/$MACHINE/tplg`

	# parse the tplg
	SSP=`echo $tplg_name |awk -F "-" '{print $2}'`
	MODE=`echo $tplg_name |awk -F "-" '{print $5}'`
	PIPELINE=`echo $tplg_name |awk -F "-" '{print $6}'`
	FORMAT_INPUT=`echo $tplg_name |awk -F "-" '{print $7}'`
	FORMAT_OUTPUT=`echo $tplg_name |awk -F "-" '{print $8}'`
	RATE=`echo $tplg_name |awk -F "-" '{print $9}'`
	MCLK=`echo $tplg_name |awk -F "-" '{print $10}'`
	CODEC=`echo $tplg_name |awk -F "-" '{print $11}'`

	# run test cases for specfied tplg
	alsactl restore -f $CURRENT_PATH/asound_state/$PLATFORM/asound.state.$PIPELINE # alsa setting
	feature_test_list # run tplg test
}

feature_test () {
	FEATURE_CUT=$((FEATURE_CNT+1))
	TEST_SUIT=$1
	TEST_CASE=$2
	TEST_PARA=$3
	LOG_FILE=$CURRENT_PATH/sof_test.log
	if [ $TEST_SUIT == "PCM_playback" ] || [ $TEST_SUIT == "pulseaudio" ]; then
		bash $CURRENT_PATH/$TEST_TYPE/$TEST_CASE.sh $RATE $FORMAT_INPUT $PIPELINE $PLATFORM # run test
		cat playback.log | while read line
		do
			TEST_CASE=`echo $line|awk -F " " '{ print $1}'`
			if [[ $line =~ FAIL ]]; then
				echo "$TEST_CASE FAIL"
				echo "testsuite_"$TEST_SUIT" testsuite_"$TEST_SUIT"_testcase_"$TEST_CASE" testtype_"$TEST_TYPE" FAIL" >> $CURRENT_PATH/sof_test.log
			else
				echo "$TEST_CASE PASS"
				echo "testsuite_"$TEST_SUIT" testsuite_"$TEST_SUIT"_testcase_"$TEST_CASE" testtype_"$TEST_TYPE" PASS" >> $CURRENT_PATH/sof_test.log
			fi
		done
	else
		bash $CURRENT_PATH/$TEST_TYPE/$TEST_CASE.sh $TEST_PARA # run test
		if [ $? -eq 0 ]; then
			FEATURE_PASS=$((FEATURE_PASS+1))
			echo "$TEST_CASE PASS"
			echo "testsuite_"$TEST_SUIT" testsuite_"$TEST_SUIT"_testcase_"$TEST_CASE" testtype_"$TEST_TYPE" PASS" >> $CURRENT_PATH/sof_test.log
		else
			echo "$TEST_CASE FAIL"
			echo "testsuite_"$TEST_SUIT" testsuite_"$TEST_SUIT"_testcase_"$TEST_CASE" testtype_"$TEST_TYPE" FAIL" >> $CURRENT_PATH/sof_test.log
		fi
	fi
	sleep 2
}

feature_test_common_list(){

	echo "now is doing the common test on $PLATFORM" >> $CURRENT_PATH/$test_report
	while read line
	do
		feature_test $line
	done < ./common-test

	# run feature test
	run_test
}

check_status () {
	tplg_max=`awk 'END{print NR}' ./$PLATFORM/$MACHINE/tplg`
	if [ -f test_status/status ]; then
		status=`cat test_status/status |awk -F ' ' '{print $1}'`
		if [ $status == "new" ]; then
			if [ ! -d "report" ]; then
				mkdir report
			fi
			test_report=report/$DATE-$PLATFORM
			echo $test_report > test_status/report
			tplg_num=1
			echo $tplg_num > test_status/tplg
			feature_test_common_list
		elif [ $status == "continue" ]; then
			test_report=`cat test_status/report |awk -F ' ' '{print $1}'`
			run_test
		elif [ $status == "done" ]; then
			echo "new" > test_status/status
			check_status
		fi
	else
		read -p  "Unable to get the test status, do you want to reset the test: Y/N?" answer
		case $answer in
		Y | y)
			reset_status;;
		N | n)
			echo "Test Exit"
			exit 0;;
		*)
		echo "error choice"
		check_status;;
		esac
	fi
}

# get platform info
get_platform() {

	MOD_VER=`lscpu |grep "Model name" |awk -F " " '{print $6}'`
	if [ $MOD_VER == "E3826" ] || [ $MOD_VER == "E3845" ]; then
		PLATFORM="byt"
		MACHINE="minnow"
		check_status
	elif [ $MOD_VER == "A3960" ]; then
		PLATFORM="apl"
		MACHINE="gp"
		MCLK=24576k
		check_status
	elif [ $MOD_VER == "N4200" ]; then
		PLATFORM="apl"
		MACHINE="up"
                MCLK=24576k
		check_status
	elif [ $MOD_VER == "0000" ]; then
		PLATFORM="cnl"
		MACHINE="cnl"
		MCLK=24000k
		check_status
	else
		echo "no matched platform, please confirm it"
		exit 1
	fi
}

# reset the test status
reset_status() {
	if [ ! -d "test_status" ]; then
		mkdir test_status
	fi
	echo "new" > test_status/status
	echo "1" > test_status/tplg
	get_platform
}

function main(){
        sleep 5

	if [ "$para" == "-r" ]; then
		reset_status
	fi
	get_platform
}

#Audio CI call main function for testing
main
