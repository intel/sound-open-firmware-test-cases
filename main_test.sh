#!/bin/bash
if [ -f sof_test.log ]; then
	rm -rf sof_test.log
fi

CURRENT_PATH=`pwd`
FEATURE_PASS=0
FEATURE_CNT=0
TEST_TYPE="functionality_test"
FIRMWARE_PATH="/lib/firmware/intel"

# default tplg

SSP=ssp2
MODE=I2S
PIPELINE=passthrough
FORMAT_INPUT=s16_le
FORMAT_OUTPUT=s16_le
RATE=48K
MCLK=19200K
CODEC=codec

# get platform info

get_platform() {

	MOD_VER=`lscpu |grep "Model name" |awk -F " " '{print $6}'`
	if [ $MOD_VER == "E3826" ]; then
		PLATFORM="byt"
		MACHINE="minnow"
		feature_test_common_list
	elif [ $MOD_VER == "A3960" ]; then
		PLATFORM="apl"
		MACHINE="gp"
		MCLK=24576K
		feature_test_common_list
	elif [ $MOD_VER == "N4200" ]; then
		PLATFORM="apl"
		MACHINE="up"
                MCLK=24576K
	elif [ $MOD_VER == "0000" ]; then
		PLATFORM="cnl"
		MACHINE="cnl"
		MCLK=24000K
		feature_test_common_list
	else
		echo "no matched platform, please confirm it"
		exit 1
	fi
}

feature_test () {
	FEATURE_CUT=$((FEATURE_CNT+1))
	TEST_SUIT=$1
	TEST_CASE=$2
	LOG_FILE=$CURRENT_PATH/sof_test.log
	if [ $TEST_SUIT == "PCM_playback" ] || [ $TEST_SUIT == "pulseaudio" ]; then
		bash $CURRENT_PATH/$TEST_TYPE/$TEST_CASE.sh $RATE $FORMAT_INPUT $PIPELINE $PLATFORM # run test
		cat playback.log | while read line
		do
			TEST_CASE=`echo $line|awk -F " " '{ print $1}'`
        		if [[ $line =~ FAIL ]]; then
				echo "$TEST_CASE FAIL"
				echo "testsuite_"$TEST_SUIT"_testcase_"$TEST_CASE"_testtype_"$TEST_TYPE" FAIL" >> $CURRENT_PATH/sof_test.log
        		else
				echo "$TEST_CASE PASS"
				echo "testsuite_"$TEST_SUIT"_testcase_"$TEST_CASE"_testtype_"$TEST_TYPE" PASS" >> $CURRENT_PATH/sof_test.log
        		fi
		done
	else			 
		bash $CURRENT_PATH/$TEST_TYPE/$TEST_CASE.sh # run test
		if [ $? -eq 0 ]; then
			FEATURE_PASS=$((FEATURE_PASS+1))
			echo "$TEST_CASE PASS"
			echo "testsuite_"$TEST_SUIT"_testcase_"$TEST_CASE" testtype_"$TEST_TYPE" PASS" >> $CURRENT_PATH/sof_test.log
		else
			echo "$TEST_CASE FAIL"
			echo "testsuite_"$TEST_SUIT"_testcase_"$TEST_CASE" testtype_"$TEST_TYPE" FAIL" >> $CURRENT_PATH/sof_test.log
		fi
	fi
	sleep 2
}

feature_test_common_list(){

	echo "now is doing the common test on $PLATFORM" >> $CURRENT_PATH/sof_test.log
	while read line
	do
		feature_test $line
	done < ./common-test

	# run feature test
	run_test
}

feature_test_list() {

	echo "now is testing $SSP-$MODE-$PIPELINE-"$FORMAT_INPUT"-"$FORMAT_OUTPUT"-$RATE-$MCLK-$CODEC tplg" >> $CURRENT_PATH/sof_test.log
	while read line
	do
		feature_test $line
	done < ./$PLATFORM/$MACHINE/feature-test
}

run_test() {

	feature_test_list # run default tplg first
	while read line
	do
		# parse the tplg
		SSP=`echo $line |awk -F "-" '{print $2}'`
		MODE=`echo $line |awk -F "-" '{print $3}'`
		PIPELINE=`echo $line |awk -F "-" '{print $4}'`
		FORMAT_INPUT=`echo $line |awk -F "-" '{print $5}'`
		FORMAT_OUTPUT=`echo $line |awk -F "-" '{print $6}'`
		RATE=`echo $line |awk -F "-" '{print $7}'`
		MCLK=`echo $line |awk -F "-" '{print $8}'`
		CODEC=`echo $line |awk -F "-" '{print $9}'`

		# relink the tplg
		if [ $PLATFORM == "byt" -a $MACHINE == "minnow" ]; then
			ln -fs $FIRMWARE_PATH/topology/$line $FIRMWARE_PATH/sof-$PLATFORM-rt5651.tplg
		elif [ $PLATFORM == "apl" -a $MACHINE == "gp" ]; then
			ln -fs $FIRMWARE_PATH/topology/$line $FIRMWARE_PATH/sof-$PLATFORM-nocodec.tplg
		elif [ $PLATFORM == "apl" -a  $MACHINE == "up"]; then
			ln -fs $FIRMWARE_PATH/topology/$line $FIRMWARE_PATH/sof-$PLATFORM-nocodec.tplg
		else
			ln -fs $FIRMWARE_PATH/topology/$line $FIRMWARE_PATH/sof-$PLATFORM.tplg
		fi
		feature_test loadable_DSP_modules check_modules_reloadable_$PLATFORM
		if [ $? == 0 ]; then
			sleep 10
			alsactl restore -f $CURRENT_PATH/asound_state/$PLATFORM/asound.state.$PIPELINE # alsa setting
			feature_test_list
		else
			echo "modules reload failed on $SSP-$MODE-"$FORMAT_INPUT"-"$FORMAT_INPUT"-$RATE-$MCLK-$CODEC tplg" >> $CURRENT_PATH/sof_test.log
		fi
	done < ./$PLATFORM/$MACHINE/tplg

}

function main(){
        sleep 5
	alsactl restore -f $CURRENT_PATH/asound_state/$PLATFORM/asound.state.$PIPELINE # alsa setting
	get_platform
}
main
