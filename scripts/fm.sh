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
DATESHORT=$(date +"%Y%m%d")
#
# ------------------------------------------------------------
# check basedir
# ------------------------------------------------------------
#
SCRIPT=$(realpath $0)					# full script name with path
SCRIPTNAME=$(basename $0)				# name of script without path
SCRIPTPATH=$(dirname $SCRIPT)			# script path dir
# basepath.txt has the base directory tree. Generate it with command: pwd > basepath.txt
BASEDIR=$(head -1 $SCRIPTPATH"/basepath.txt")
# log filename
LOGFILE=$BASEDIR"/scripts/log/rftrack-$DATESHORT.log"
#
# log function
function echo_log {
    echo $(date +%Y/%m/%d:%H:%M:%S)"[$SCRIPTNAME]|$1" >> $LOGFILE
}

echo $SCRIPT
echo $SCRIPTPATH
echo $BASEDIR
echo $LOGFILE
# ---------------
echo_log $SCRIPT
echo_log $SCRIPTPATH
echo_log $BASEDIR
echo_log $LOGFILE
# list of directories
#

echo "exit to prompt"