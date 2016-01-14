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
# This script check db file stored in db directory to generate video, with filename stored in sig file
#
DATESHORT=$(date +"%Y%m%d")
#
# ------------------------------------------------
# check multiple instance of script
me=$(basename $0)								# name of script without path
LOCKFILE="/tmp/lock-"$me						# name of lockfile
if [ -e ${LOCKFILE} ] && kill -0 $(cat ${LOCKFILE}); then
    echo $me "Already running!"
    exit 1
fi
trap "rm -f ${LOCKFILE}; exit" INT TERM EXIT	# automatic remove lockfile when exit
echo $$ > ${LOCKFILE}							# store PID number in lockfile
# end check multiple instance
# ------------------------------------------------
#
SCRIPT=$(realpath $0)					# full script name with path
SCRIPTNAME=$(basename $0)				# name of script without path
SCRIPTPATH=$(dirname $SCRIPT)			# script path dir
#
# log filename
LOGFILE=$SCRIPTPATH"/log/$DATESHORT-sigvideo.log"
#
# log function
function echo_log {
    echo $(date +%Y/%m/%d:%H:%M:%S)"[$SCRIPTNAME]|$1" >> $LOGFILE
}
#
# ---------------------------------------------------
# directory with sig attachments
DIRSIGDB=$SCRIPTPATH"/sig/dbvideo/"
echo_log "---------------- Start video generation"
#
# get the oldest sig file
sigfile=$(ls -t $DIRSIGDB 2> /dev/null  | tail -1)
# verify if there are no sig files
if [ -z "${sigfile}" ]; then
    echo_log "no sig file or no db received"
	exit 1
fi
#
# get the db name inside the sig file to analyze
echo_log "get sigfile:["$sigfile"]"
#
# get the name of file to analyze
dbfile=$(head -n 1 $DIRSIGDB$sigfile)
echo_log "db to analyze:["$dbfile"]"
dbname=$(basename $dbfile)								# name of db without path
echo_log "name of db:["$dbname"]"
dbfilenoext="${dbfile%.*}"								# db file name without extension
dbnamenoext="${dbname%.*}"								# db name without extension
#
# ---------------------------------------
# generate the first video from db 
echo_log "Start video1 generation"
$SCRIPTPATH/video.sh $dbfile
echo_log "End video1 generation"

# copy the files in the report maps directory
cp $SCRIPTPATH/video/$dbnamenoext/video.mp4 $SCRIPTPATH/maps/$dbnamenoext/filedown/video.mp4
cp $SCRIPTPATH/docfiles/ico/video_measures.png $SCRIPTPATH/maps/$dbnamenoext/ico/video_measures.png
#
# ---------------------------------------
# generate the second video db 
echo_log "Start video2 generation"
$SCRIPTPATH/video2osm.sh $dbfile
echo_log "End video2 generation"

# copy the files in the report maps directory
cp $SCRIPTPATH/video/$dbnamenoext/video2.mp4 $SCRIPTPATH/maps/$dbnamenoext/filedown/video2.mp4
cp $SCRIPTPATH/docfiles/ico/video_measures.png $SCRIPTPATH/maps/$dbnamenoext/ico/video_measures2.png
#
# ---------------------------------------
# copy all video to remote destination directory
#
# copy video1 to remote
$SCRIPTPATH/cpydest.sh $SCRIPTPATH/maps/$dbnamenoext/filedown/video.mp4 /$dbnamenoext/filedown $LOGFILE
$SCRIPTPATH/cpydest.sh $SCRIPTPATH/maps/$dbnamenoext/ico/video_measures.png /$dbnamenoext/ico $LOGFILE
#
# copy video2 to remote
$SCRIPTPATH/cpydest.sh $SCRIPTPATH/maps/$dbnamenoext/filedown/video2.mp4 /$dbnamenoext/filedown $LOGFILE
$SCRIPTPATH/cpydest.sh $SCRIPTPATH/maps/$dbnamenoext/ico/video_measures2.png /$dbnamenoext/ico $LOGFILE
#
# ---------------------------------------
# remove sig file and dbfile
rm -f $DIRSIGDB$sigfile
rm -f $dbfile
rm -f $dbfilenoext".key"
echo_log "---------------- End video generation"

# end of script
