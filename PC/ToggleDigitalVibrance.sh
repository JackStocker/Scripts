#!/bin/bash
CSGO=500
DEFAULT=100

if [[ $(nvidia-settings -q "DigitalVibrance" | grep "Attribute.*$CSGO\.") ]]
then
    nvidia-settings -a "DigitalVibrance=$DEFAULT" > /dev/null
    notify-send --hint int:transient:1 "Digital Vibrance" "Set to Default"
else 
    nvidia-settings -a "DigitalVibrance=$CSGO" > /dev/null
    notify-send --hint int:transient:1 "Digital Vibrance" "Set to CSGO"
fi
