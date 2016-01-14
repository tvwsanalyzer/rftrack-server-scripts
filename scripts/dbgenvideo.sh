#!/bin/bash
# ------------------------------------------------------------
# This script generate the video using heatfilm.R
#
# ------------------------------------------
# see: http://stackoverflow.com/questions/2151212/how-can-i-read-command-line-parameters-from-an-r-script
# read command line arguments
# Add this to the top of your script:
# args<-commandArgs(TRUE)
# Then you can refer to the arguments passed as args[1], args[2] etc.
# Then run
# Rscript myscript.R arg1 arg2 arg3
# If your args are strings with spaces in them, enclose within double quotes.
# ------------------------------------------
# 
# ----------------------------------------------------------------------------
if [ "$#" -ne 2 ]; then
    echo "--------------------------------------------------------------------------------------"
    echo "Illegal number of parameters"
	echo "This script create film from a RfTrack db."
    echo "Use: $0 <db_path> <config id>"
	echo "example:"
	echo "$0 ./db/fes.db 1"
	echo "Analyze ./db/fes.db with config id 1"
    echo "--------------------------------------------------------------------------------------"
	echo ""
	exit 1
fi

filename=$1
dbname="${filename##*/}"			# file name with extension
basename=${dbname%.*}				# filename without extension


# create the video elaboration directory
mkdir ./video/maps
mkdir ./video/graphs
mkdir ./video/total

# Clean temporary files created for video
echo "Clean previous temporary files used for video"
rm -f ./video/maps/*.png
rm -f ./video/graphs/*.png
rm -f ./video/total/*.png
#

mkdir ./video/$basename
./dban $filename $2 -G > ./video/$basename/perc.txt

length=$(tail -1 ./video/$basename/perc.txt | head -1 | awk -F";" '{print $1}')

Rscript heatfilm.R ./video/$basename/perc.txt

#
# ----------------------------------------------------------------------------
# ANALYSIS CYCLE
#
for i in $(seq "$length"); 
do
# create the sort id for file name
sort_id=$( printf "%06d" $i )

montage -geometry 480 "./video/graphs/"$sort_id"_graph.png" "./video/maps/"$sort_id"_map.png" "./video/total/"$sort_id"_frame.png"
# montage -geometry 600 "./graphs/"$sort_id"_graph.png" "./maps/"$sort_id"_map.png" "./total/"$sort_id"_frame.png"

done
# ----------------------------------------------------------------------------
#
echo "End of analysis cycle."
echo "Create video.."
# ----------------------------------------------------------------------------
# Create video:
#
# convert -delay 5 total/total_[1-9].png total/total_[1-9][0-9].png total/total_[1-9][0-9][0-9].png total/total_[1-9][0-9][0-9][0-9].png total/total_[1-9][0-9][0-9][0-9][0-9].png output.mov 
# convert -delay 5 total/[0-9][0-9][0-9][0-9][0-9][0-9]_frame.png output.mov
rm ./video/$basename/video.mp4
ffmpeg -framerate 25 -i ./video/total/%06d_frame.png -c:v libx264 -profile:v high -crf 20 -pix_fmt yuv420p ./video/$basename/video.mp4

# ----------------------------------------------------------------------------
#
echo "<<<--- End   [$0]"

