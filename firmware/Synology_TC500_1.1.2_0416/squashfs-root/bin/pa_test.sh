#!/bin/sh

echo "Set config for PA test..."

# main profile
diag action=update key=VideoSource.0.VideoProfile.0.Resolution strval=2880x1620
sleep 0.5
diag action=update key=VideoSource.0.VideoProfile.0.H264.RateControl strval=cbr
sleep 0.2
diag action=update key=VideoSource.0.VideoProfile.0.H264.BitRate intval=8192
sleep 0.2
diag action=update key=VideoSource.0.VideoProfile.0.FPS intval=30
sleep 0.5

# sub profile
diag action=update key=VideoSource.0.VideoProfile.1.Resolution strval=1920x1080
sleep 0.5
diag action=update key=VideoSource.0.VideoProfile.1.H264.RateControl strval=cbr
sleep 0.2
diag action=update key=VideoSource.0.VideoProfile.1.H264.BitRate intval=2048
sleep 0.2
diag action=update key=VideoSource.0.VideoProfile.1.FPS intval=15
sleep 0.5

# power freq
diag action=update key=VideoSource.0.ISP.PowerFrequency intval=60
sleep 0.1

# time osd
diag action=update key=VideoSource.0.Overlay.Text.DateEnabled boolval=false
sleep 0.1
diag action=update key=VideoSource.0.Overlay.Text.TimeEnabled boolval=false
sleep 0.1
diag action=update key=VideoSource.0.Overlay.Text.TextEnabled boolval=false
sleep 0.1

# irled
diag action=update key=IRLED.Enabled boolval=true
sleep 0.1
diag action=update key=IRLED.Intensity intval=90
sleep 0.1

# led
diag action=update key=LED.Enabled boolval=false
sleep 0.1

# rtsp
diag action=update key=Network.Streaming.RTSP.Path.0.AccessName strval=1
sleep 0.1
diag action=update key=Network.Streaming.RTSP.Path.1.AccessName strval=2
sleep 0.1
diag action=update key=Network.Streaming.RTSP.Authentication strval=none
sleep 0.1

diag action=update key=Network.0.BootProto strval=static
sleep 0.1

# disable recording
diag action=update key=VideoSource.0.Motion.0.Enabled boolval=false
sleep 0.1
diag action=update key=VideoSource.0.Motion.1.Enabled boolval=false
sleep 0.1
diag action=update key=VideoSource.0.Motion.2.Enabled boolval=false
sleep 0.1
diag action=update key=VideoSource.0.Motion.3.Enabled boolval=false
sleep 0.1
diag action=update key=VideoSource.0.Motion.Tamper.Enabled boolval=false
sleep 0.1
diag action=update key=AudioSource.0.SoundDetect.Enabled boolval=false
sleep 0.1
diag action=update key=Custom.Activated boolval=false
sleep 0.1
diag action=update key=Custom.Edge.Mode intval=0
sleep 0.1

# debug mode
diag action=update key=Custom.DebugMode boolval=true
sleep 0.1

echo "Set config for PA test...ok"
