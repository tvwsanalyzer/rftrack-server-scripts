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
# Script continuously detect new files(s) in Dropbox dir, db or dbvideo directories
# ------------------------------------------------------------
#
# list of full path of programs
SCRIPT=$(realpath $0)					# full script name with path
SCRIPTPATH=$(dirname $SCRIPT)			# script path dir
#
# Dropbox directory to monitor: check arrive db
DIRATTACH=$(head -1 $SCRIPTPATH"/dropattach.txt")
DIRDB=$SCRIPTPATH"/db"
DIRDBVIDEO=$SCRIPTPATH"/dbvideo"
#
# list of signal directories
DIRSIGATTACH=$SCRIPTPATH"/sig/Attachments"
DIRSIGDB=$SCRIPTPATH"/sig/db"
DIRSIGDBVIDEO=$SCRIPTPATH"/sig/dbvideo"
#
#
# check Dropbox directory and store sig file
chkdropbox() {
	local fullname
	local extension			# filename extension
	local filename			# filename without extension
	local DATELOG
	local LOGFILE
	local SIGFILE

	while read line
	do
		fullname=$DIRATTACH/$line
		extension="${line##*.}"			# filename extension
		filename=${line%.*}				# filename without extension
		DATELOG=$(date +%Y%m%d)
		LOGFILE=$SCRIPTPATH"/log/"$DATELOG"_dbmon.log"
		SIGFILE=$DIRSIGATTACH/$filename".sig"
		echo $(date +%Y%m%d:%H:%M:%S) "close_write: $line"  >> $LOGFILE
		# if file is db, execute script 
		if [ "$extension" = "db" ]
        then
			echo "$DIRATTACH/$line"  > $SIGFILE
		fi
	done < <(inotifywait -m -e close_write -e moved_to "$1" --format '%f')
}

# check db directory and store sig file
chkdirdb() {
	local fullname
	local extension			# filename extension
	local filename			# filename without extension
	local DATELOG
	local LOGFILE
	local SIGFILE

	while read line
	do
		fullname=$DIRDB/$line
		extension="${line##*.}"			# filename extension
		filename=${line%.*}				# filename without extension
		DATELOG=$(date +%Y%m%d)
		LOGFILE=$SCRIPTPATH"/log/"$DATELOG"_dbmon.log"
		SIGFILE=$DIRSIGDB/$filename".sig"
		echo $(date +%Y%m%d:%H:%M:%S) "close_write: $line"  >> $LOGFILE
		# if file is db, execute script 
		if [ "$extension" = "db" ]
        then
			echo "$DIRDB/$line"  > $SIGFILE
		fi
	done < <(inotifywait -m -e close_write -e moved_to "$1" --format '%f')
}

# check video db directory and store sig file
chkdirdbvideo() {
	local fullname
	local extension			# filename extension
	local filename			# filename without extension
	local DATELOG
	local LOGFILE
	local SIGFILE

	while read line
	do
		fullname=$DIRDBVIDEO/$line
		extension="${line##*.}"			# filename extension
		filename=${line%.*}				# filename without extension
		DATELOG=$(date +%Y%m%d)
		LOGFILE=$SCRIPTPATH"/log/"$DATELOG"_dbmon.log"
		SIGFILE=$DIRSIGDBVIDEO/$filename".sig"
		echo $(date +%Y%m%d:%H:%M:%S) "close_write: $line"  >> $LOGFILE
		# if file is db, execute script 
		if [ "$extension" = "db" ]
        then
			echo "$DIRDBVIDEO/$line"  > $SIGFILE
		fi
	done < <(inotifywait -m -e close_write -e moved_to "$1" --format '%f')
}

# launch monitor functions
chkdropbox "$DIRATTACH" &
chkdirdb "$DIRDB" &
chkdirdbvideo "$DIRDBVIDEO" &
echo "exit to prompt"