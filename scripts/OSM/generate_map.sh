#!/bin/bash
width=480
height=480
lat="$1"
long="$2"
zoom=12
if [ -n "$3" ]; then
    zoom="$3"
fi
#filename="$lat-$long-$zoom-${width}x$height.png"
wget "http://maps.google.com/maps/api/staticmap?center=$lat,$long&zoom=$zoom&size=${width}x${height}&sensor=false" -O "img.png"
# small error checking
if [ $? -ne 0 ]; then
    echo "An error occured" >&2
    exit 1
fi
echo "Generato mappa!"
