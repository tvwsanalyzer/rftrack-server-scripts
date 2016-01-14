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
# This script create a backup of all script in server
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
# ---------------------------------------------------
# Dropbox directory to monitor: check arrive db
DIRBACKUP=$(head -1 $SCRIPTPATH"/dropbackup.txt")

7z a -y $DIRBACKUP"/scripts/"$DATESHORT"-scripts.7z" @$SCRIPTPATH/lstscripts.lst

# --------------------------------------------
# NOTE:
# To restore the files from backup, use the command:
# 7z x -y <name of archive>.7z
# --------------------------------------------
#
# end of script
