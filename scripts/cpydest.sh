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
# This script copy files to the remote destination directory
# Author: Marco Rainone
# Ver. 1.3, 2015/10/11
#
# log date format
DATELOG='date +%Y/%m/%d:%H:%M:%S'
DATESHORT=$(date +"%Y%m%d")
#
function echo_log {
    echo `$DATELOG`" $1" >> $LOGFILE
}
if [ "$#" -ne 3 ]; then
	LOGFILE="/var/log/cpydest.log"
    echo_log "--------------------------------------------------------------------------------------"
    echo_log "Illegal number of parameters"
	echo_log "This script copy files to the remote destination directory."
    echo_log "Use: $0 <filename or directory> <destination> <LOGFILE>"
	echo_log "example:"
	echo_log "$0 test.html / log123.log"
    echo_log "--------------------------------------------------------------------------------------"
	echo_log ""
	exit 1
fi
LOGFILE=$3				# $3 = log name
# log the script call
echo_log "--->>> Start [$0 $1 $2 $3]"
# -----------------------------------------------------------------
# check if the data passed is a file or directory
if [ -d "$1" ] ; then
    # is a directory
	FTY="dir "
else
    if [ -f "$1" ]; then
        # is a file
		FTY="file"
	else
        echo_log "$1 is not a valid item to copy"
        exit 1
    fi
fi
# -----------------------------------------------------------------
#
SRC=$1
REMOTE="mzennaro@140.105.28.91:/Volumes/ELEARNING/WIRELESS/wireless/tvws"
DEST=$REMOTE$2
echo_log "Source $FTY:[$SRC]"
echo_log "Destination:[$DEST]"
#
chmod -R 775 $SRC 
# chmod -R a+r $SRC 
scp -rp $SRC $DEST
#
echo_log "$FTY copied to:  [$DEST]"
#
echo_log "<<<--- End   [$0]"
# end of script
