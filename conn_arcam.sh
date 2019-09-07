#!/bin/bash

# TODO
# 1. turn on blutooth if not already on
# 2. show user the available streams and take an input choice

# https://unix.stackexchange.com/questions/65246/change-pulseaudio-input-output-from-shell/67398

# Get the arcam info firstly:
# $pactl list short sinks
#	bluez_sink.00_1B_7C_03_6D_69	module-bluetooth-device.c	s16le 2ch 44100Hz	RUNNING

# Arcam ID
bt_device='bluez_sink.00_1B_7C_03_6D_69'
#sennheiser_m2='bluez_sink.00_1B_66_80_98_8D'
isFound=0

# hdmi                  = index 0 output
# stereo speakers       = index 4 output
# bluetooth headphones  = index 8 output
#blueStream=8
spotifyStream="s16le"

echo "Usage: $0 <sinkId/sinkName>" >&2
echo ""
echo "Connect to bluetooth device..."
# Connect to bluetooth headphone (will work even if already connected)
bt-audio -c "Arcam Bluetooth"
echo ""
echo "Valid sinks:" >&2
pactl list short sinks >&2
echo ""
echo "Available audio streams:" >&2 
pactl list short sink-inputs >&2

if [ -z "$1" ]; then
    exit 1
fi
userSelectStream=$1

# List the audio outputs possible
pactl list short sinks|while read stream; do
    sink=$(echo $stream|cut -d ' ' -f2)
    echo "sink type = $sink"
    if [ "$bt_device" = "$sink" ]; then
        echo "sink found!"
        isFound=1
    fi
    # if last round, exit if not found
    #echo $isFound
done

# Move Spotify streaming to sink, if not already connected
pactl list short sink-inputs|while read stream; do
    streamId=$(echo $stream|cut '-d ' -f1)
    connId=$(echo $stream|cut '-d ' -f2)
    audioId=$(echo $stream|cut '-d ' -f5)
    
    if [ "$spotifyStream" = "$audioId" ]; then
        if [ $connId == $userSelectStream ]; then
            echo "Bluetooth device already connected, exiting."
            exit 0
        else
            echo "moving stream $streamId to bluetooth device:$userSelectStream" 
            pactl move-sink-input "$streamId" "$userSelectStream"
        fi
    fi
done


