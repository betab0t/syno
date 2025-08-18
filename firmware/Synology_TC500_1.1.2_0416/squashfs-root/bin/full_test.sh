#!/bin/sh

start_full_loading_test()
{
	echo "Start full loading test..."

	killall cpu_burnin.sh > /dev/null 2>&1

	# check SD card first
	SD_STATUS=`diag action=list key=Storage.0.Status`
	if [ $SD_STATUS == "DEACTIVE" ]; then
		echo "Error! SD card is not mounted."
		exit 1
	fi

	# set video profile to maximum capability
	diag action=update key=VideoSource.0.VideoProfile.0.Resolution strval=2880x1620
	sleep 0.5
	VID_RES=`diag action=list key=VideoSource.0.VideoProfile.0.Resolution`
	if [ "$VID_RES" != "2880x1620" ]; then
		echo "Set VideoSource.0.VideoProfile.0.Resolution fail! ret=$VID_RES"
		exit 1;
	else
		echo "Set VideoSource.0.VideoProfile.0.Resolution to $VID_RES"
	fi

	diag action=update key=VideoSource.0.VideoProfile.0.H264.RateControl strval=cbr
	sleep 0.5
	VID_RC=`diag action=list key=VideoSource.0.VideoProfile.0.H264.RateControl`
	if [ "$VID_RC" != "cbr" ]; then
		echo "Set VideoSource.0.VideoProfile.0.H264.RateControl fail! ret=$VID_RC"
		exit 1;
	else
		echo "Set VideoSource.0.VideoProfile.0.H264.RateControl to $VID_RC"
	fi

	diag action=update key=VideoSource.0.VideoProfile.0.H264.BitRate intval=8192
	sleep 0.5
	VID_BR=`diag action=list key=VideoSource.0.VideoProfile.0.H264.BitRate`
	if [ "$VID_BR" != "8192" ]; then
		echo "Set VideoSource.0.VideoProfile.0.H264.BitRate fail! ret=$VID_BR"
		exit 1;
	else
		echo "Set VideoSource.0.VideoProfile.0.H264.BitRate to $VID_BR"
	fi

	diag action=update key=VideoSource.0.VideoProfile.0.FPS intval=30
	sleep 0.5
	VID_FPS=`diag action=list key=VideoSource.0.VideoProfile.0.FPS`
	if [ "$VID_FPS" != "30" ]; then
		echo "Set VideoSource.0.VideoProfile.0.FPS fail! ret=$VID_FPS"
		exit 1;
	else
		echo "Set VideoSource.0.VideoProfile.0.FPS to $VID_FPS"
	fi

	diag action=update key=VideoSource.0.VideoProfile.1.Resolution strval=1920x1080
	sleep 0.5
	VID_RES=`diag action=list key=VideoSource.0.VideoProfile.1.Resolution`
	if [ "$VID_RES" != "1920x1080" ]; then
		echo "Set VideoSource.0.VideoProfile.1.Resolution fail! ret=$VID_RES"
		exit 1;
	else
		echo "Set VideoSource.0.VideoProfile.1.Resolution to $VID_RES"
	fi

	diag action=update key=VideoSource.0.VideoProfile.1.H264.RateControl strval=cbr
	sleep 0.5
	VID_RC=`diag action=list key=VideoSource.0.VideoProfile.1.H264.RateControl`
	if [ "$VID_RC" != "cbr" ]; then
		echo "Set VideoSource.0.VideoProfile.1.H264.RateControl fail! ret=$VID_RC"
		exit 1;
	else
		echo "Set VideoSource.0.VideoProfile.1.H264.RateControl to $VID_RC"
	fi

	diag action=update key=VideoSource.0.VideoProfile.1.H264.BitRate intval=2048
	sleep 0.5
	VID_BR=`diag action=list key=VideoSource.0.VideoProfile.1.H264.BitRate`
	if [ "$VID_BR" != "2048" ]; then
		echo "Set VideoSource.0.VideoProfile.1.H264.BitRate fail! ret=$VID_BR"
		exit 1;
	else
		echo "Set VideoSource.0.VideoProfile.1.H264.BitRate to $VID_BR"
	fi

	diag action=update key=VideoSource.0.VideoProfile.1.FPS intval=15
	sleep 0.5
	VID_FPS=`diag action=list key=VideoSource.0.VideoProfile.1.FPS`
	if [ "$VID_FPS" != "15" ]; then
		echo "Set VideoSource.0.VideoProfile.1.FPS fail! ret=$VID_FPS"
		exit 1;
	else
		echo "Set VideoSource.0.VideoProfile.1.FPS to $VID_FPS"
	fi

	# enable full time recording
	diag action=update key=Recorder.0.Enabled boolval=true
	sleep 0.5
	RECORD_STA=`diag action=list key=Recorder.0.Enabled`
	if [ "$RECORD_STA" != "true" ]; then
		echo "Set Recorder.0.Enabled fail! ret=$RECORD_STA"
		exit 1;
	else
		echo "Set Recorder.0.Enabled to $RECORD_STA"
	fi

	# show time osd
	diag action=update key=VideoSource.0.Overlay.Text.DateEnabled boolval=true
	diag action=update key=VideoSource.0.Overlay.Text.TimeEnabled boolval=true
	touch /tmp/time_updated
	sleep 1

	cpu_burnin.sh &
	sleep 0.5
	BURNIN_PID=`pidof cpu_burnin.sh`
	if [ "$BURNIN_PID" == "" ]; then
		echo "Run cpu_burnin.sh fail!"
		exit 1;
	else
		echo "Run cpu_burnin.sh ok, pid=$BURNIN_PID"
	fi

	echo "Start full loading test ...ok"

	exit 0;
}

stop_full_loading_test()
{
	echo "Stop full loading test..."

	killall cpu_burnin.sh > /dev/null 2>&1
	sleep 0.5

	# disable full time recording
	diag action=update key=Recorder.0.Enabled boolval=false
	sleep 0.5

	echo "Stop full loading test ...ok"

	exit 0;
}

if [ "$1" == "" ] || [ "$1" == "start" ]; then
	start_full_loading_test
elif [ "$1" == "stop" ]; then
	stop_full_loading_test
else
	echo "Unsupported cmd: $1"
	exit 1;
fi
