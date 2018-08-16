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
PIPELINE=volume
FORMAT_INPUT=s16le
FORMAT_OUTPUT=s16le
RATE=48k
MCLK=19200k
CODEC=codec

# get platform info

get_platform() {

	MOD_VER=`lscpu |grep "Model name" |awk -F " " '{print $6}'`
	if [ $MOD_VER == "E3826" ] || [ $MOD_VER == "E3845" ]; then
		PLATFORM="byt"
		MACHINE="minnow"
		alsactl restore -f $CURRENT_PATH/asound_state/$PLATFORM/asound.state.$PIPELINE # alsa setting
		feature_test_common_list
	elif [ $MOD_VER == "A3960" ]; then
		PLATFORM="apl"
		MACHINE="gp"
		MCLK=24576k
		alsactl restore -f $CURRENT_PATH/asound_state/$PLATFORM/asound.state.$PIPELINE # alsa setting
		feature_test_common_list
	elif [ $MOD_VER == "N4200" ]; then
		PLATFORM="apl"
		MACHINE="up"
                MCLK=24576k
		alsactl restore -f $CURRENT_PATH/asound_state/$PLATFORM/asound.state.$PIPELINE # alsa setting
		feature_test_common_list
	elif [ $MOD_VER == "0000" ]; then
		PLATFORM="cnl"
		MACHINE="cnl"
		MCLK=24000k
		alsactl restore -f $CURRENT_PATH/asound_state/$PLATFORM/asound.state.$PIPELINE # alsa setting
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

	echo "now is doing the common test on $PLATFORM" >> $CURRENT_PATH/sof_test.log
	while read line
	do
		feature_test $line
	done < ./common-test

	# run feature test
	run_test
}

feature_test_list() {
	tplg_file=`find $FIRMWARE_PATH -name "sof-*.tplg"`
	link_path=`readlink $tplg_file`
	link_file=${link_path##*/}

	echo "now is testing $link_file" >> $CURRENT_PATH/sof_test.log
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
		MODE=`echo $line |awk -F "-" '{print $5}'`
		PIPELINE=`echo $line |awk -F "-" '{print $6}'`
		FORMAT_INPUT=`echo $line |awk -F "-" '{print $7}'`
		FORMAT_OUTPUT=`echo $line |awk -F "-" '{print $8}'`
		RATE=`echo $line |awk -F "-" '{print $9}'`
		MCLK=`echo $line |awk -F "-" '{print $10}'`
		CODEC=`echo $line |awk -F "-" '{print $11}'`

		# relink the tplg
		if [ $PLATFORM == "byt" -a $MACHINE == "minnow" ]; then
			ln -fs $FIRMWARE_PATH/topology/$line $FIRMWARE_PATH/sof-$PLATFORM-rt5651.tplg
		elif [ $PLATFORM == "apl" -a $MACHINE == "gp" ]; then
			ln -fs $FIRMWARE_PATH/topology/$line $FIRMWARE_PATH/sof-$PLATFORM-nocodec.tplg
		elif [ $PLATFORM == "apl" -a  $MACHINE == "up" ]; then
			ln -fs $FIRMWARE_PATH/topology/$line $FIRMWARE_PATH/sof-$PLATFORM-nocodec.tplg
		else
			ln -fs $FIRMWARE_PATH/topology/$line $FIRMWARE_PATH/sof-$PLATFORM.tplg
		fi

		feature_test loadable_DSP_modules modules_reload
		if [[ $? == 0 ]]; then
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
	get_platform
}
#Audio CI call main function for testing
#main
