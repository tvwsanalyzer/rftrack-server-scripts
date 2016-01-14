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
# This script create a backup index page and index db in server
#
DATESHORT=$(date +"%Y%m%d")
DATEFULL=$(date +"%Y%m%d%H%M%S")
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

7z a -y $DIRBACKUP"/indexpage/"$DATEFULL"-index.7z" @$SCRIPTPATH/lstindex.lst

# Set up the number of days for backup rotation
NUMDAYS=14
# change date file:
#  touch -d 20120101 goldenfile
# Search for backup older than NUMDAYS days and remove them. This makes possible rotation of backups
for i in $(find $DIRBACKUP/indexpage/*.7z -mtime +$NUMDAYS);
do
	rm $i
done

# --------------------------------------------
# NOTE:
# To restore the files from backup, use the command:
# 7z x -y <name of archive>.7z
# --------------------------------------------
#
# end of script
