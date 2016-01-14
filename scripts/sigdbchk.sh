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
# This script check db file stored in Dropbox, with filename stored in sig file
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
LOGFILE=$SCRIPTPATH"/log/$DATESHORT-sigdbchk.log"
#
# log function
function echo_log {
    echo $(date +%Y/%m/%d:%H:%M:%S)"[$SCRIPTNAME]|$1" >> $LOGFILE
}
#
# ---------------------------------------------------
# directory with sig attachments
DIRSIGATTACH=$SCRIPTPATH"/sig/Attachments/"
echo_log "---------------- Start analysis"
#
# get the oldest sig file
sigfile=$(ls -t $DIRSIGATTACH 2> /dev/null  | tail -1)
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
dbfile=$(head -n 1 $DIRSIGATTACH$sigfile)
echo_log "db to analyze:["$dbfile"]"
#
# ---------------------------------------
# backup db index and index page
echo_log "backup index page"
$SCRIPTPATH/bkpindex.sh

# ---------------------------------------
# check the db 
echo_log "Start dbchk"
$SCRIPTPATH/dbchk $dbfile db archive
echo_log "End dbchk"
#
# ---------------------------------------
# copy the html index of reports to remote destination directory
#
# update the report campaign index
$SCRIPTPATH/cpydest.sh $SCRIPTPATH/maps/index.html / $LOGFILE
$SCRIPTPATH/cpydest.sh $SCRIPTPATH/maps/Shuttleworth_Funded.jpg  / $LOGFILE
$SCRIPTPATH/cpydest.sh $SCRIPTPATH/maps/idximages / $LOGFILE
$SCRIPTPATH/cpydest.sh $SCRIPTPATH/maps/jscript / $LOGFILE
#
# ---------------------------------------
# remove sig file and dbfile
rm -f $DIRSIGATTACH$sigfile
rm -f $dbfile
echo_log "---------------- End analysis"

# end of script
