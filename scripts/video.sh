#!/bin/bash
# ========================================================================
# Copyright (c) 2014-2016
# - Wireless T/ICT4D Lab (http://wireless.ictp.it/) &
# - Marco Rainone (https://www.linkedin.com/in/marcorainone)
# This file is part of project RfTrack - White Space Analyzer.
# This is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
# ========================================================================
#
# ------------------------------------------------------------
# This script generate the first video (video.mp4) using heatfilm.R
#
SCRIPT=$(realpath $0)					# full script name with path
SCRIPTNAME=$(basename $0)				# name of script without path
SCRIPTPATH=$(dirname $SCRIPT)			# script path dir
#
export PATH=$PATH:$SCRIPTPATH:$SCRIPTPATH/OSM
#
# ----------------------------------------------------------------------------
if [ "$#" -ne 1 ]; then
    echo "--------------------------------------------------------------------------------------"
    echo "Illegal number of parameters"
	echo "This script create film from a RfTrack db."
    echo "Use: $0 <db_path>"
	echo "example:"
	echo "$0 ./db/fes.db"
	echo "Analyze ./db/fes.db with config id max(config_id)"
    echo "--------------------------------------------------------------------------------------"
	echo ""
	exit 1
fi

filename=$1
dbname="${filename##*/}"			# file name with extension
basename=${dbname%.*}				# filename without extension

# create the video elaboration directories
mkdir -p $SCRIPTPATH/video
mkdir -p $SCRIPTPATH/video/maps
mkdir -p $SCRIPTPATH/video/graphs
mkdir -p $SCRIPTPATH/video/total
#
# create the video destination
mkdir -p $SCRIPTPATH/video/$basename

# Clean temporary files created for video
echo "Clean previous temporary files used for video"
rm -f $SCRIPTPATH/video/maps/*.png
rm -f $SCRIPTPATH/video/graphs/*.png
rm -f $SCRIPTPATH/video/total/*.png
#
# remove old video results
rm -f $SCRIPTPATH/video/$basename/perc.txt
rm -f $SCRIPTPATH/video/$basename/video.mp4

#
# elaborate the video image
$SCRIPTPATH/dban $filename 0 -G $SCRIPTPATH/video/$basename/perc.txt

length=$(tail -1 $SCRIPTPATH/video/$basename/perc.txt | head -1 | awk -F";" '{print $1}')

Rscript $SCRIPTPATH/heatfilm.R $SCRIPTPATH/video/$basename/perc.txt

#
# ----------------------------------------------------------------------------
# ANALYSIS CYCLE
#
for i in $(seq "$length"); 
do
# create the sort id for file name
sort_id=$( printf "%06d" $i )

montage -geometry 480 $SCRIPTPATH"/video/graphs/"$sort_id"_graph.png" $SCRIPTPATH"/video/maps/"$sort_id"_map.png" $SCRIPTPATH"/video/total/"$sort_id"_frame.png"
# montage -geometry 600 $SCRIPTPATH"/graphs/"$sort_id"_graph.png" $SCRIPTPATH"/maps/"$sort_id"_map.png" "./total/"$sort_id"_frame.png"

# remove images used to prepare frame
rm $SCRIPTPATH"/video/graphs/"$sort_id"_graph.png"
rm $SCRIPTPATH"/video/maps/"$sort_id"_map.png"

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
rm -f $SCRIPTPATH/video/$basename/video.mp4
ffmpeg -framerate 25 -i $SCRIPTPATH/video/total/%06d_frame.png -c:v libx264 -profile:v high -crf 20 -pix_fmt yuv420p $SCRIPTPATH/video/$basename/video.mp4

# ----------------------------------------------------------------------------
#
echo "<<<--- End   [$0]"

