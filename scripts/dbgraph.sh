#!/bin/bash
# ------------------------------------------------------------
# This script creates the html files with data analysis of the RfTrack campaign database
# Author: Marco Rainone
# Ver. 1.3, 2015/10/11
#
# ------------------------------------------------------------
# to use inside a cron job
# act_path="/root/scripts"
# cd $act_path
#
# log date format
DATELOG='date +%Y/%m/%d:%H:%M:%S'
DATESHORT=$(date +"%Y%m%d")
#
function echo_log {
    echo `$DATELOG`" $1" >> $LOGFILE
}
if [ "$#" -ne 2 ]; then
	LOGFILE="/var/log/dbcampaigngraph-$DATESHORT.log"
    echo_log "--------------------------------------------------------------------------------------"
    echo_log "Illegal number of parameters"
	echo_log "This script creates the html files with data analysis of the RfTrack campaign database."
    echo_log "Use: $0 <database name> <LOGFILE>"
	echo_log "example:"
	echo_log "$0 test.db log123.log"
    echo_log "--------------------------------------------------------------------------------------"
	echo_log ""
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
    echo_log "Error: database "$1" not found!"
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
mkdir -p $outdir								# directory with html output
mkdir -p $outdir/"jscript"						# directory with java script used in html output
dochtml=$outdir/"index.html"					# output report
idxhtml="maps/index.html"						# output index of reports
mkdir -p "maps/jscript"							# directory with java script used in html index file
#
# echo_log "script dbgraph.sh"
echo_log "Database: $1"
echo_log "Output document: "$dochtml
#
# -----------------------------------------------------------------
# Generate the html report
# -----------------------------------------------------------------
#
# generate the data for video mp4
(cat ./cmd/gpsfreqdbm.sql | sqlite3 db/$database) | sed '0~112g' > tmp/gpsfreqdbm.txt
#
# generate the spectral map
# !!! For old versions of RfTrack the data must be divided by 2
# (cat ./cmd/seldatadiv2.sql | sqlite3 db/$database) | sed '0~112g' > tmp/data_okok.txt
# !!! For versions of Rftrack post 0.55
(cat ./cmd/seldata.sql | sqlite3 db/$database) | sed '0~112g' > tmp/data_okok.txt
./cmd/specmap.sh
#
# temporary files created with specmap.sh
# start_time=$(cat ./tmp/start_time.txt)
# lat_long=$(cat ./tmp/latlong.txt)
#
# ----------------------------------------------
# Modify 15/10: create two new graph with scripts OSM/marco.sh. 
# marco.sh call OSM/gnu_plot_percentage.sh, gnu_plot_noise.sh
# gnu_plot_percentage.sh create OSM/graph_index_perc.png
# gnu_plot_noise.sh create OSM/graph_index_noise.png
# remove old graph
rm ./OSM/graph_index_perc.png						# remove image
rm ./OSM/graph_index_noise.png						# remove image
# chiamato dalla root di scripts per problemi path. SISTEMARE!!!!
./marco.sh
# copy the two graphs
cp ./OSM/graph_index_perc.png $outdir				# copy image
cp ./OSM/graph_index_noise.png $outdir				# copy image
#
# -----------------------------------------------------------------
# generate the html document
echo_log "Extract positions..."
(cat ./cmd/selpos.sql | sqlite3 db/$database) > ./tmp/data_loc.txt
#
# -----------------------------------------------------------------
# copy the elements to form the document
cp ./tmp/spectral-map.png $outdir				# spectral map image
# copy page elements
cp ./docfiles/*.png $outdir						# copy images
cp ./docfiles/style.css $outdir					# copy style.css
# copy javascript
cp ./docfiles/*.js $outdir/"jscript"			# copy all javascript files
cp ./docfiles/js $outdir/"jscript"
# copy temporary video measure and video ico
cp ./docfiles/video.mp4 $outdir					# copy video.
cp ./docfiles/video_measures_creating.png $outdir/video_measures.png
#
# -----------------------------------------------------------------
echo_log "Create html document..."
cp ./pmh/pmh01.txt $dochtml						# start the html document
#
# ------------- standard sections
echo_log "RfTrack database campaign: " $database >> $dochtml
cat ./pmh/pmh02.txt >> $dochtml
awk '{ print "var map = L.map(\x27map\x27).setView([" $1 "," $2 "],12);" }' < ./tmp/latlong.txt >> $dochtml
cat ./pmh/pmh03.txt >> $dochtml
awk '{ print "var marker" NR " = L.marker([" $1 "," $2 "], {icon: mrk}).bindPopup(\x27 [" $1 ", " $2 ", " $3 "]<br>\x27).addTo(map);" }' < ./tmp/data_loc.txt > ./tmp/pmhloc.txt
cat ./tmp/pmhloc.txt >> $dochtml
cat ./pmh/pmh04.txt >> $dochtml
#
# ------------- here add new sections: 
# to add text, modify pmh05other.txt or add other files
# cat ./pmh/pmh05other.txt >> $dochtml
#
# ------------- end of new sections
cat ./pmh/pmh06end.txt >> $dochtml				# end the html document
#
# -----------------------------------------------------------------
# Update the html index of reports
# -----------------------------------------------------------------
#
echo_log "Create html index document..."
cp ./idm/idm01.txt $idxhtml						# start the html document
#
# update the marker list of campaigns
awk -v fname=$filename '{ print "var marker = L.marker([" $1 "," $2 "], {icon: mrk}).bindPopup(\x27 " fname "<br>[" $1 ", " $2 "]<br>\x27).addTo(map);" }' < ./tmp/latlong.txt > ./tmp/idmloc.txt
cp ./idm/idm02marker.txt ./tmp/idmsv2.txt
cat ./tmp/idmloc.txt ./tmp/idmsv2.txt > ./idm/idm02marker.txt
cat ./idm/idm02marker.txt >> $idxhtml			# add marker list to document
#
cat ./idm/idm03.txt >> $idxhtml
#
# get the report list
echo "<li><a href=\"./"$filename"/index.html\"><img src=\"./"$filename"/spectral-map.png\" width=\"20%\" height=\"20%\"></a>" $filename  > ./tmp/newrep.txt
cat ./tmp/start_time.txt >> ./tmp/newrep.txt
cat ./tmp/latlong.txt >> ./tmp/newrep.txt
echo "<a href=\"./"$filename"/video.mp4\"><img src=\"./"$filename"/video_measures.png\" width=\"20%\" height=\"20%\"></a>" >> ./tmp/newrep.txt
echo "</li>" >> ./tmp/newrep.txt
cp ./idm/idm04report.txt ./tmp/idmsv4.txt
cat ./tmp/newrep.txt ./tmp/idmsv4.txt > ./idm/idm04report.txt
cat ./idm/idm04report.txt >> $idxhtml			# add report list to document
# ------------- end of sections
cat ./idm/idm05end.txt >> $idxhtml				# end the html document
#
# -----------------------------------------------------------------
# copy the elements to form the document
# copy page elements
cp ./docfiles/mrkico.png ./maps					# copy image
cp ./docfiles/mrkshadow.png ./maps				# copy image
cp ./docfiles/Shuttleworth_Funded.jpg ./maps	# copy image
#
cp ./docfiles/style.css ./maps					# copy style.css
# copy javascript
cp ./docfiles/*.js ./maps/jscript				# copy all javascript files
cp ./docfiles/js ./maps/jscript
#
# -----------------------------------------------------------------
# calculate the execution time
tend=$(date +"%s")								# end time execution
# echo $tend
diff=$(($tend-$tstart))							# time execution (sec)
echo_log "Script execution time: "$diff" sec"
#
echo_log "<<<--- End   [$0]"
# end of script
