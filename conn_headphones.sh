#!/bin/bash

# https://unix.stackexchange.com/questions/65246/change-pulseaudio-input-output-from-shell/67398

sennheiser_m2='bluez_sink.00_1B_66_80_98_8D'
isFound=0

# hdmi                  = index 0 output
# stereo speakers       = index 4 output
# bluetooth headphones  = index 8 output
#blueStream=8
spotifyStream="s16le"

echo "Usage: $0 <sinkId/sinkName>" >&2
echo ""
echo "Connect to bluetooth headset..."
# Connect to bluetooth headphone (will work even if already connected)
bt-audio -c "MOMENTUM M2 OEBT"
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

# List the audio outputs possible - look for headphones
pactl list short sinks|while read stream; do
    sink=$(echo $stream|cut -d ' ' -f2)
    echo "sink type = $sink"
    if [ "$sennheiser_m2" = "$sink" ]; then
        echo "sink found!"
        isFound=1
    fi
    # if last round, exit if not found
    #echo $isFound
done

# Move Spotify streaming to headphones, if not already connected
pactl list short sink-inputs|while read stream; do
    streamId=$(echo $stream|cut '-d ' -f1)
    connId=$(echo $stream|cut '-d ' -f2)
    audioId=$(echo $stream|cut '-d ' -f5)
    
    if [ "$spotifyStream" = "$audioId" ]; then
        if [ $connId == $userSelectStream ]; then
            echo "Bluetooth headphones are already connected, exiting."
            exit 0
        else
            echo "moving stream $streamId to bluetooth headphones:$userSelectStream" 
            pactl move-sink-input "$streamId" "$userSelectStream"
        fi
    fi
done


