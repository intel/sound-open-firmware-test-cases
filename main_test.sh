#!/bin/bash
if [ -f sof_test.log ]; then
	rm -rf sof_test.log
fi

current_path=`pwd`
feature_pass=0
feature_cnt=0
test_type="functionality_test"

feature_test () {

	feature_cnt=$((feature_cnt+1))
	test_suit=$1
	test_case=$2
	log_file=$current_path/sof_test.log
	if [ $test_suit == "PCM_playback" ] || [ $test_suit == "pulseaudio" ]; then
		bash $current_path/$test_type/$test_case.sh # run test
		cat playback.log | while read line
		do
        		test_case=`echo $line|awk -F " " '{ print $1}'`
        		if [[ $line =~ FAIL ]]; then
				echo "$test_case FAIL"
                		echo "testsuite_"$test_suit" testsuite_"$test_suit"_testcase_"$test_case" testtype_"$test_type" FAIL" >> $current_path/sof_test.log
        		else
				echo "$test_case PASS"
                		echo "testsuite_"$test_suit" testsuite_"$test_suit"_testcase_"$test_case" testtype_"$test_type" PASS" >> $current_path/sof_test.log
        		fi
		done
	else			 
		bash $current_path/$test_type/$test_case.sh # run test
		if [ $? -eq 0 ]; then
			feature_pass=$((feature_pass+1))
			echo "$test_case PASS"
			echo "testsuite_"$test_suit" testsuite_"$test_suit"_testcase_"$test_case" testtype_"$test_type" PASS" >> $current_path/sof_test.log
		else
			echo "$test_case FAIL"
			echo "testsuite_"$test_suit" testsuite_"$test_suit"_testcase_"$test_case" testtype_"$test_type" FAIL" >> $current_path/sof_test.log
		fi
	fi
	sleep 2
}

feature_test_list(){

	feature_test information_detection verify_sof_firmware_presence
	feature_test information_detection verify_sof_firmware_load
#	feature_test information_detection verify_topology_load
	feature_test information_detection verify_sof_firmware_version_info
	feature_test information_detection playack_pcm_list
#	feature_test information_detection estimate_firmware_loaded_time
	feature_test information_detection verify_sound_modules
	feature_test information_detection verify_playback_pcm0_info
	feature_test information_detection capture_pcm_list
	feature_test information_detection verify_capture_info
	feature_test information_detection verify_playback_pcm_list
	feature_test information_detection Audio_device_check
	feature_test loadable_DSP_modules check_48k16bit_passthrough_playback
#	feature_test information_detection check_modules_unloadable
#	feature_test loadable_DSP_modules check_modules_loading_time
#	feature_test loadable_DSP_modules check_modules_reloadable
#	feature_test loadable_DSP_modules check_playback_after_modules_reloaded
	feature_test PCM_playback check_48k16bit_passthrough_playback
	feature_test PCM_playback check_line_in_out_playback_function
	feature_test PCM_playback single_channel_playback_test
	feature_test PCM_playback two_channels_playback_test
#	feature_test pause_resume check_media_pipeline_pause_resume
#	feature_test pause_resume check_low_latency_pipeline_pause_resume
#	feature_test pause_resume check_passthrough_pipeline_pause_resume
#	feature_test pulseaudio check_passthrough_pulseaudio_playback_function
#	feature_test pulseaudio	check_passthrough_pulseaudio_capture_function
	feature_test volume_control get_mixer_properties
	feature_test volume_control set_HP_volume_to_minimum
	feature_test volume_control set_HP_volume_to_maximum
	feature_test volume_control set_ADC_volume_to_minimum
	feature_test volume_control set_ADC_volume_to_maximum
}

function main(){
	alsactl restore -f $current_path/asound_state/asound.state.passthrough # alsa setting
        sleep 5
	feature_test_list
}

main
