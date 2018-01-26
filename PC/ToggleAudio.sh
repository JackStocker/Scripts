#!/bin/bash

HEADPHONES_DEVICE="alsa_output.usb-Kingston_HyperX_7.1_Audio_00000000-00.analog-stereo"
MOBO_DEVICE="alsa_output.pci-0000_00_1b.0.analog-stereo"

# Get the current device
pactl info | grep "Default Sink" | grep $MOBO_DEVICE
MOBO_SELECTED=$?

if [ "$MOBO_SELECTED" -eq "1" ]; then
#   pacmd set-default-sink $MOBO_DEVICE
   ./SetAudioSink.sh $MOBO_DEVICE
   notify-send --expire-time=500 --hint int:transient:1 "Audio" "Set audio device to Motherboard"
else
#   pacmd set-default-sink $HEADPHONES_DEVICE
   ./SetAudioSink.sh $HEADPHONES_DEVICE
   notify-send --expire-time=500 --hint int:transient:1 "Audio" "Set audio device to Headphones"
fi
