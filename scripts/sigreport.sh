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
# This script check db file stored in db directory to generate report, with filename stored in sig file
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
LOGFILE=$SCRIPTPATH"/log/$DATESHORT-sigreport.log"
#
# log function
function echo_log {
    echo $(date +%Y/%m/%d:%H:%M:%S)"[$SCRIPTNAME]|$1" >> $LOGFILE
}
#
# ---------------------------------------------------
# directory with sig attachments
DIRSIGDB=$SCRIPTPATH"/sig/db/"
echo_log "---------------- Start analysis"
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
# generate the report from db 
echo_log "Start report generation"
$SCRIPTPATH/report.sh $dbname $LOGFILE
echo_log "End report generation"
#
# ---------------------------------------
# copy report to remote destination directory
#
# copy report to remote
$SCRIPTPATH/cpydest.sh $SCRIPTPATH/maps/$dbnamenoext / $LOGFILE
#
# ---------------------------------------
# remove sig file and dbfile
rm -f $DIRSIGDB$sigfile
rm -f $dbfile
rm -f $dbfilenoext".key"
echo_log "---------------- End analysis"

# end of script
