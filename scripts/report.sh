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
# Script to create html analysis report of the RfTrack campaign database
# Author: Marco Rainone
# Ver. 1.4, 2015/12/11
#
# ------------------------------------------------------------
# to use inside a cron job
# act_path="/root/scripts"
# cd $act_path
#
SCRIPT=$(realpath $0)					# full script name with path
SCRIPTNAME=$(basename $0)				# name of script without path
SCRIPTPATH=$(dirname $SCRIPT)			# script path dir
# basepath.txt has the base directory tree. Generate it with command: pwd > basepath.txt
BASEDIR=$(head -1 $SCRIPTPATH"/basepath.txt")
DATESHORT=$(date +"%Y%m%d")
#
# log function
function echo_log {
    echo $(date +%Y/%m/%d:%H:%M:%S)"[$SCRIPTNAME]|$1" >> $LOGFILE
}
#
if [ "$#" -ne 2 ]; then
	LOGFILE="/var/log/report-$DATESHORT.log"
    echo "--------------------------------------------------------------------------------------"
    echo "Illegal number of parameters"
	echo "This script creates the html files with data analysis of the RfTrack campaign database."
    echo "Use: $0 <database name> <LOGFILE>"
	echo "example:"
	echo "$0 test.db log123.log"
    echo "--------------------------------------------------------------------------------------"
	echo ""
	exit 1
fi
LOGFILE=$2				# $2 = log name
# log the script call
echo_log "--->>> Start [$0 $1 $2]"
# -----------------------------------------------------------------
#
tstart=$(date +"%s")							# start time execution
# echo $tstart
#
# -----------------------------------------------------------------
# create directory used in script (-p this will also create any intermediate directories that don't exist)
mkdir -p db
mkdir -p maps
mkdir -p tmp
#
# -----------------------------------------------------------------
# check if the database exist
if [ ! -f ./db/$1 ]; then
    echo "Error: database "$1" not found!"
	exit 1
fi
# -----------------------------------------------------------------
# clear temporary
rm ./tmp/*.*									# for security clear tmp directory
#
# -----------------------------------------------------------------
# prepare output name
database=$1										# input database
filename=$(basename $1 ".db")					# name without extension
outdir=maps/$filename							# output directory
#
dochtml=$outdir/"index.html"					# output file html report
htmlforpdf=$outdir/"pdfrep.html"				# output file html report for pdf
pdfrep=$outdir/"filedown/report.pdf"			# output report in pdf
#
idxhtml="maps/index.html"						# file output index of reports
mkdir -p "maps/jscript"							# directory with java script used in html index file
#
# create all report directories
mkdir -p $outdir								# directory with html output
mkdir -p $outdir/"jscript"						# directory with java script used in html output
mkdir -p $outdir/"ico"							# directory with image icons
mkdir -p $outdir/"images"						# directory with graphs images
mkdir -p $outdir/"filedown"						# directory with download files
#
# echo "script dbcampaigngraph.sh"
echo_log "Database: $1"
echo_log "Output document: "$dochtml
#
# -----------------------------------------------------------------
# Generate the html report
# -----------------------------------------------------------------
#
# ./dbgengraph.sh ./db/$database 1
# 0 is for max(config_id)
./dbgengraph.sh ./db/$database 0

# copy the graphs
# cp ./flagcountry.png $outdir/"images"					# copy image
cp ./graph_index_perc.png $outdir/"images"				# copy image
cp ./graph_index_perc-hires.png $outdir/"images"		# copy image
cp ./graph_index_noise.png $outdir/"images"				# copy image
cp ./graph_index_noise-hires.png $outdir/"images"		# copy image
cp ./spectral-map.png $outdir/"images"					# spectral map image
cp ./spectral-map-hires.png $outdir/"images"			# spectral map image
cp ./histogram_85.png $outdir/"images"					# copy image
cp ./histogram_90.png $outdir/"images"					# copy image
cp ./histogram_95.png $outdir/"images"					# copy image
cp ./histogram_100.png $outdir/"images"					# copy image
cp ./perc_85.png $outdir/"images"						# copy image
cp ./perc_90.png $outdir/"images"						# copy image
cp ./perc_95.png $outdir/"images"						# copy image
cp ./perc_100.png $outdir/"images"						# copy image
cp ./maproute.png $outdir/"images"						# spectral map image
cp ./maproute-hires.png $outdir/"images"				# spectral map image

#
# -----------------------------------------------------------------
# generate the html document
echo_log "Extract positions..."
# disabilitato temp
# (cat ./cmd/selpos.sql | sqlite3 db/$database) > ./tmp/data_loc.txt
#
# -----------------------------------------------------------------
# copy the elements to form the document
# copy page elements
# cp ./docfiles/jscript/style.css $outdir			# copy style.css
cp ./docfiles/jscript/*.* $outdir/"jscript/"		# copy all script files

cp ./docfiles/ico/*.* $outdir/"ico/"				# copy ico images

# copy temporary video ico
cp ./docfiles/"ico/video_measures_creating.png" $outdir/"ico/video_measures.png"	# copy video1 temp ico
cp ./docfiles/"ico/video_measures_creating.png" $outdir/"ico/video_measures2.png"	# copy video2 temp ico
# copy temporary video
cp ./docfiles/filedown/video_creating.mp4 $outdir/"filedown/video.mp4"		# copy video1.
cp ./docfiles/filedown/video_creating.mp4 $outdir/"filedown/video2.mp4"		# copy video.
# copy database in filedown
cp ./db/$database $outdir/"filedown/measures.db"	# sqlite db to download
# create image archive
# 7z a -tzip $outdir/"filedown/images.zip" $outdir/"img/"	
zip -r -j $outdir/"filedown/images" $outdir/"images"	
#
# copy download page
cp ./page_download/download.html $outdir/
cp ./page_download/"ico/download.png" $outdir/"ico/"
cp ./page_download/"ico/sqlite_banner.png" $outdir/"ico/"
cp ./page_download/"ico/Shuttleworth_Funded.jpg" $outdir/"ico/"
cp ./page_download/ico/*.png $outdir/"ico/"
#
# -----------------------------------------------------------------
echo_log "Create html document..."
cp ./pmh/pmh01a.txt $dochtml					# start the html document
cat ./pmh/pmh01position.txt >> $dochtml
cat ./pmh/pmh02end.txt >> $dochtml				# end the html document
#
echo_log "Create the pdf report..."
cp ./pmh/pre01a.txt $htmlforpdf					# start the html document
cat ./pmh/pmh01position.txt >> $htmlforpdf
cat ./pmh/pre02end.txt >> $htmlforpdf			# end the html document
# generate the pdf report
# for server linux:
# call wkhtmltopdf with xvfb-run:
# xvfb-run wkhtmltopdf $1.html $2.pdf
xvfb-run wkhtmltopdf $htmlforpdf $pdfrep

# cat ./pmh/pmh01c.txt >> $dochtml
#
# ------------- standard sections
# echo "RfTrack database campaign: " $database >> $dochtml
# cat ./pmh/pmh02.txt >> $dochtml
# da aggiuntere DISAB TEMPORANEAMENTE!!!!!!!!!!!!!!
# awk '{ print "var map = L.map(\x27map\x27).setView([" $1 "," $2 "],12);" }' < ./tmp/latlong.txt >> $dochtml
# cat ./pmh/pmh03.txt >> $dochtml
# da aggiuntere DISAB TEMPORANEAMENTE!!!!!!!!!!!!!!!
# awk '{ print "var marker" NR " = L.marker([" $1 "," $2 "], {icon: mrk}).bindPopup(\x27 [" $1 ", " $2 ", " $3 "]<br>\x27).addTo(map);" }' < ./tmp/data_loc.txt > ./tmp/pmhloc.txt
# cat ./tmp/pmhloc.txt >> $dochtml
# cat ./pmh/pmh04.txt >> $dochtml
#
# ------------- here add new sections: 
# to add text, modify pmh05other.txt or add other files
# cat ./pmh/pmh05other.txt >> $dochtml
#
# ------------- end of new sections
#
# -----------------------------------------------------------------
# Update the html index of reports
# -----------------------------------------------------------------
#
#	echo "Create html index document..."
#	cp ./idm/idm01.txt $idxhtml						# start the html document
#	#
#	# update the marker list of campaigns
#	awk -v fname=$filename '{ print "var marker = L.marker([" $1 "," $2 "], {icon: mrk}).bindPopup(\x27 " fname "<br>[" $1 ", " $2 "]<br>\x27).addTo(map);" }' < ./tmp/latlong.txt > ./tmp/idmloc.txt
#	cp ./idm/idm02marker.txt ./tmp/idmsv2.txt
#	cat ./tmp/idmloc.txt ./tmp/idmsv2.txt > ./idm/idm02marker.txt
#	cat ./idm/idm02marker.txt >> $idxhtml			# add marker list to document
#	#
#	cat ./idm/idm03.txt >> $idxhtml
#	#
#	# get the report list
#	echo "<li><a href=\"./"$filename"/index.html\"><img src=\"./"$filename"/spectral-map.png\" width=\"20%\" height=\"20%\"></a>" $filename  > ./tmp/newrep.txt
#	cat ./tmp/start_time.txt >> ./tmp/newrep.txt
#	cat ./tmp/latlong.txt >> ./tmp/newrep.txt
#	echo "<a href=\"./"$filename"/video.mp4\"><img src=\"./"$filename"/video_measures.png\" width=\"20%\" height=\"20%\"></a>" >> ./tmp/newrep.txt
#	echo "</li>" >> ./tmp/newrep.txt
#	cp ./idm/idm04report.txt ./tmp/idmsv4.txt
#	cat ./tmp/newrep.txt ./tmp/idmsv4.txt > ./idm/idm04report.txt
#	cat ./idm/idm04report.txt >> $idxhtml			# add report list to document
#	# ------------- end of sections
#	cat ./idm/idm05end.txt >> $idxhtml				# end the html document
#	#
#	# -----------------------------------------------------------------
#	# copy the elements to form the document
#	# copy page elements
#	cp ./docfiles/mrkico.png ./maps					# copy image
#	cp ./docfiles/mrkshadow.png ./maps				# copy image
#	cp ./docfiles/Shuttleworth_Funded.jpg ./maps	# copy image
#	#
#	cp ./docfiles/style.css ./maps					# copy style.css
#	# copy javascript
#	cp ./docfiles/*.js ./maps/jscript				# copy all javascript files
#	cp ./docfiles/js ./maps/jscript
#	#
# -----------------------------------------------------------------
# calculate the execution time
tend=$(date +"%s")								# end time execution
# echo $tend
diff=$(($tend-$tstart))							# time execution (sec)
echo_log "Script execution time: "$diff" sec"
#
echo_log "<<<--- End   [$0]"
# end of script
