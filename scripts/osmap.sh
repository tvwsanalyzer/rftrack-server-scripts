#!/bin/bash
# ------------------------------------------------------------
# This script create the video from the RfTrack data
# Author: Marco Rainone
# Modified to use openstreetmaps with Maperitive, in place to google maps
# Ver. 1.1, 2015/10/11
#
# log date format
DATELOG='date +%Y/%m/%d:%H:%M:%S'
DATESHORT=$(date +"%Y%m%d")
#
function echo_log {
    echo `$DATELOG`" $1" >> $LOGFILE
}
if [ "$#" -ne 1 ]; then
	LOGFILE="/var/log/osmap.log"
    echo_log "--------------------------------------------------------------------------------------"
    echo_log "Illegal number of parameters"
	echo_log "This script create the video from the RfTrack data."
    echo_log "Use: $0 <LOGFILE>"
	echo_log "example:"
	echo_log "$0 log123.log"
    echo_log "--------------------------------------------------------------------------------------"
	echo_log ""
	exit 1
fi
LOGFILE=$1				# $1 = log name
# log the script call
echo_log "--->>> Start [$0 $1]"
# -----------------------------------------------------------------
#
cp ../tmp/gpsfreqdbm.txt data.txt
length=$(tail -2 data.txt | head -1 | awk -F"\t" '{print $1}')

# ----------------------------------------------------------------------------
# Clean temporary files created for video
echo_log "Clean previous temporary files used for video"
rm ./maps/*.*
rm ./graphs/*.*
rm ./total/*.*
#
echo_log "Start analysis cycle. Number of video frames: $length"
#
# ----------------------------------------------------------------------------
# ANALYSIS CYCLE
#
for i in $(seq "$length"); 
do

tstart=$(date +"%s")							# start time execution

# create the sort id for file name
sort_id=$( printf "%06d" $i )
#

head -n 112 data.txt > temp.txt
head -n 1 temp.txt > temp_gps.txt

lat=$(awk -F"\t" '{print $2}' temp_gps.txt) 
lon=$(awk -F"\t" '{print $3}' temp_gps.txt)

echo $i $lat $lon
#
# original
# ./generate_map.sh $lat $lon 14
# gnuplot plo
# mv map.png ./maps/image_$i.png
#
# create the map and update maps
./map.sh $lat $lon $sort_id

# Generate gnuplot graphs from the blocks of 112 lines

head -n 111 temp.txt > temp_db.txt

awk -F"\t" '{print $4}' temp_db.txt | cut -c1-3 > first_column_ok.txt
awk -F"\t" '{print $5}' temp_db.txt > second_column_ok.txt

paste first_column_ok.txt second_column_ok.txt > ready_for_graph.txt 

./gnu_plot.sh 

mv graph.png "./graphs/"$sort_id"_graph.png"

montage -geometry 480 "./graphs/"$sort_id"_graph.png" "./maps/"$sort_id"_map.png" "./total/"$sort_id"_frame.png"

tail -n +113 data.txt > temp.txt 
mv temp.txt data.txt
rm first_column_ok.txt second_column_ok.txt
rm temp_gps.txt
rm temp_db.txt

tend=$(date +"%s")								# end time execution
diff=$(($tend-$tstart))							# time execution (sec)

if [ $i -eq 1 ]; then
	# first cycle: estimate the frame generation time
	tmin=$(( ( diff * length ) / 60 ))
	tendcycle=$( date -d "$tmin minute" )
	echo_log "Estimate time to create "$length" frames: "$tmin" min"
	echo_log "End cycle time: $tendcycle"
fi

# sleep 10
done
# ----------------------------------------------------------------------------
#
echo_log "End of analysis cycle."
#
# clean intermediate data
rm ./maps/*.*
rm ./graphs/*.*
#
echo_log "Create video.."
# ----------------------------------------------------------------------------
# Create video:
#
# convert -delay 5 total/total_[1-9].png total/total_[1-9][0-9].png total/total_[1-9][0-9][0-9].png total/total_[1-9][0-9][0-9][0-9].png total/total_[1-9][0-9][0-9][0-9][0-9].png output.mov 
# convert -delay 5 total/[0-9][0-9][0-9][0-9][0-9][0-9]_frame.png output.mov
rm video.mp4
ffmpeg -framerate 25 -i ./total/%06d_frame.png -c:v libx264 -profile:v high -crf 20 -pix_fmt yuv420p video.mp4

# ----------------------------------------------------------------------------
#
echo_log "<<<--- End   [$0]"
# End of video creation
#


