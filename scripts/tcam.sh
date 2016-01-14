#!/bin/bash
# ------------------------------------------------------------
# Script to update campaign without modify index page
#
# ------------------------------------------------------------
# check if script already running
#
# http://stackoverflow.com/questions/16807876/shell-script-execution-check-if-it-is-already-running-or-not
lockdir=/tmp/lockdir_campaign_rrZZ50lT5Y0kp74Nh5jK7aqvuLA6IL78f980zp0cTs3YkwtiJ0
#
function finish {
	# Your cleanup code here
	# last code: remove lockdir
	rmdir $lockdir
}
#
mkdir $lockdir  || {
    # lock directory exists. exiting
    exit 1
}
# take pains to remove lock directory when script terminates
# trap "rmdir $lockdir" EXIT INT KILL TERM
trap finish EXIT INT KILL TERM
# 
# ------------------------------------------------------------
# log date format
DATELOG='date +%Y/%m/%d:%H:%M:%S'
# log file
DATESHORT=$(date +"%Y%m%d")
# LOGFILE="/root/scripts/log/campaign-$DATESHORT.log"
LOGFILE="./log/campaign-$DATESHORT.log"
#
function echo_log {
    echo `$DATELOG`" $1" >> $LOGFILE
}
# ------------------------------------------------------------
#
# start script
echo_log "--------------------------- [$0]"
#
#!!!! # files=$(ls /root/scripts/*.db 2> /dev/null | wc -l)
#!!!! files=$(ls /root/Dropbox/Apps/Attachments/*.db 2> /dev/null | wc -l)
#!!!! 
#!!!! if [ "$files" == "0" ]
#!!!! then
#!!!!     echo_log "No new database found."
#!!!! 	exit 0
#!!!! fi
#!!!! 
#!!!! # to use as cron job
#!!!! act_path="/root/scripts"
#!!!! echo_log "actual path = [$act_path]"
#!!!! cd $act_path

# ----------------------------------------------
# new database received via email
# ----------------------------------------------
#
# original:
# filename=$(ls /root/Dropbox/Apps/Attachments/*.db)
# modify 13/10
# http://www.binarytides.com/linux-find-command-examples/
#!!!! filename=$(find /root/Dropbox/Apps/Attachments -maxdepth 1 -type f -name *.db | head -1)
filename=$1			# debug
#
fileis="${filename##*/}"
echo_log "Exists a database with name $fileis"
echo_log "Processing file"
# ----------------------------------------------
# copy from dropbox the db attachment
# original
# cp /root/Dropbox/Apps/Attachments/$fileis /root/scripts/db/$fileis
#
# Modify MR 17/09/2015:
# copy the db. If there is a db with a same name, rename the copy adding a number
# filename without extension
#
basename=${fileis%.*}
dest_dir="/root/scripts/db"
outname=${basename}

# ##### disabled
#
####  if [[ ! -e "$dest_dir/$basename.db" ]]; then
####  	# file does not exist in the destination directory
####  	outname=${basename}
####  else
####  	num=2
####  	while [[ -e "$dest_dir/$basename$num.db" ]]; do
####  		(( num++ ))
####  	done
####  	outname=${basename}${num}
####  fi
#

#!!!! cp /root/Dropbox/Apps/Attachments/$fileis /root/scripts/db/$outname.db
# update the destination db file name
fileis=${outname}".db"
#
# ----------------------------------------------
#!!!! /root/scripts/dbgraph.sh $fileis $LOGFILE
# generate images for report (use max(id) config table)
./dbgengraph.sh ./db/$fileis 0
#
#!!!! /root/scripts/percentage.sh $LOGFILE
#!!!! echo_log "/root/scripts/graph.sh"
#!!!! /root/scripts/graph.sh

# ---------
# original
# filename2=$(/usr/bin/basename $filename ".db")  
# name without extension
filename2=${outname}
echo_log "Destination: [$filename2]"
# ---------

#!!!! mv /root/scripts/*.png /root/scripts/maps/$filename2
outdir=maps/$filename2							# output directory
mkdir -p $outdir								# directory with html output
mkdir -p $outdir/"jscript"						# directory with java script used in html output
dochtml=$outdir/"index.html"					# output report
idxhtml="maps/index.html"						# output index of reports
mkdir -p "maps/jscript"							# directory with java script used in html index file

# copy the graphs
cp ./flagcountry.png $outdir					# copy image
cp ./graph_index_perc.png $outdir				# copy image
cp ./graph_index_perc-hires.png $outdir			# copy image
cp ./graph_index_noise.png $outdir				# copy image
cp ./graph_index_noise-hires.png $outdir		# copy image
cp ./spectral-map.png $outdir					# spectral map image
cp ./spectral-map-hires.png $outdir				# spectral map image
cp ./histogram_85.png $outdir					# copy image
cp ./histogram_90.png $outdir					# copy image
cp ./histogram_95.png $outdir					# copy image
cp ./histogram_100.png $outdir					# copy image
cp ./perc_85.png $outdir						# copy image
cp ./perc_90.png $outdir						# copy image
cp ./perc_95.png $outdir						# copy image
cp ./perc_100.png $outdir						# copy image
cp ./maproute.png $outdir					# spectral map image
cp ./maproute-hires.png $outdir				# spectral map image

# -----------------------------------------------------------------
# copy the elements to form the document
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
# "Create html document..."
cp ./pmh/pmh01a.txt $dochtml					# start the html document
cat ./pmh/pmh01position.txt >> $dochtml
cat ./pmh/pmh01c.txt >> $dochtml

# ------------- standard sections
# echo "RfTrack database campaign: " $database >> $dochtml
cat ./pmh/pmh02.txt >> $dochtml
# ------------- end of new sections
cat ./pmh/pmh06end.txt >> $dochtml				# end the html document

# Copy db in dbarchive
#!!!! mv /root/scripts/$fileis /root/scripts/dbarchive

# Copy html page to destination
echo_log "Copying dir with html report to destination"
#!!!! cp /root/scripts/maps/$filename2 /root/scripts/htmlpage 

# modify 12/10
# chmod -R 775 /root/scripts/maps/$filename2 
# chmod -R a+r /root/scripts/maps/$filename2 
# original
# scp -rp /root/scripts/maps/$filename2 mzennaro@140.105.28.91:/Volumes/ELEARNING/WIRELESS/wireless/tvws/campaigns/
# modify 18/09
# scp -rp /root/scripts/maps/$filename2 mzennaro@140.105.28.91:/Volumes/ELEARNING/WIRELESS/wireless/tvws/
#!!!! /root/scripts/cpydest.sh /root/scripts/maps/$filename2 / $LOGFILE

# Delete all files created during process

# rm /root/scripts/db/$fileis
# rm $filename

#!!!! start_time=$(cat /root/scripts/tmp/start_time.txt)
#!!!! lat_long=$(cat /root/scripts/tmp/latlong.txt)
start_time=$(cat ./tmp/start_time.txt)
lat_long=$(cat ./tmp/latlong.txt)

# -----------------------------------------------------------------
# Update the html index of reports
# -----------------------------------------------------------------
#
echo_log "Create html index document..."
cp ./idm/idm01.txt $idxhtml						# start the html document
#
# update the marker list of campaigns
awk -v fname=$outname '{ print "var marker = L.marker([" $1 "," $2 "], {icon: mrk}).bindPopup(\x27 " fname "<br>[" $1 ", " $2 "]<br>\x27).addTo(map);" }' < ./tmp/latlong.txt > ./tmp/idmloc.txt
cp ./idm/idm02marker.txt ./tmp/idmsv2.txt
cat ./tmp/idmloc.txt ./tmp/idmsv2.txt > ./idm/idm02marker.txt
cat ./idm/idm02marker.txt >> $idxhtml			# add marker list to document
#
cat ./idm/idm03.txt >> $idxhtml
#
# get the report list
# echo "<li><a href=\"./"$filename"/index.html\"><img src=\"./"$filename"/spectral-map.png\" width=\"20%\" height=\"20%\"></a>" $filename  > ./tmp/newrep.txt
# cat ./tmp/start_time.txt >> ./tmp/newrep.txt
# cat ./tmp/latlong.txt >> ./tmp/newrep.txt
# echo "<a href=\"./"$filename"/video.mp4\"><img src=\"./"$filename"/video_measures.png\" width=\"20%\" height=\"20%\"></a>" >> ./tmp/newrep.txt
# echo "</li>" >> ./tmp/newrep.txt
# cp ./idm/idm04report.txt ./tmp/idmsv4.txt
# cat ./tmp/newrep.txt ./tmp/idmsv4.txt > ./idm/idm04report.txt
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

# update the campaign index
#	# change the permissions
#	chmod -R 775 /root/scripts/maps/index.html
#	chmod -R 775 /root/scripts/maps/mrkico.png
#	chmod -R 775 /root/scripts/maps/mrkshadow.png
#	chmod -R 775 /root/scripts/maps/Shuttleworth_Funded.jpg 
#	chmod -R 775 /root/scripts/maps/style.css 
#	chmod -R 775 /root/scripts/maps/jscript
#	#
#	# 3) use scp to copy all files in the remote server
#	scp -rp /root/scripts/maps/index.html mzennaro@140.105.28.91:/Volumes/ELEARNING/WIRELESS/wireless/tvws/
#	scp -rp /root/scripts/maps/mrkico.png mzennaro@140.105.28.91:/Volumes/ELEARNING/WIRELESS/wireless/tvws/
#	scp -rp /root/scripts/maps/mrkshadow.png mzennaro@140.105.28.91:/Volumes/ELEARNING/WIRELESS/wireless/tvws/
#	scp -rp /root/scripts/maps/Shuttleworth_Funded.jpg mzennaro@140.105.28.91:/Volumes/ELEARNING/WIRELESS/wireless/tvws/
#	scp -rp /root/scripts/maps/style.css mzennaro@140.105.28.91:/Volumes/ELEARNING/WIRELESS/wireless/tvws/
#	scp -rp /root/scripts/maps/jscript mzennaro@140.105.28.91:/Volumes/ELEARNING/WIRELESS/wireless/tvws/
#
# ------------------------
# update the campaign index
#!!!! /root/scripts/cpydest.sh /root/scripts/maps/index.html / $LOGFILE
#!!!! /root/scripts/cpydest.sh /root/scripts/maps/mrkico.png / $LOGFILE
#!!!! /root/scripts/cpydest.sh /root/scripts/maps/mrkshadow.png / $LOGFILE
#!!!! /root/scripts/cpydest.sh /root/scripts/maps/Shuttleworth_Funded.jpg  / $LOGFILE
#!!!! /root/scripts/cpydest.sh /root/scripts/maps/style.css / $LOGFILE
#!!!! /root/scripts/cpydest.sh /root/scripts/maps/jscript / $LOGFILE

# Controlla posta cosi messaggi risultano letti
#/usr/bin/fetchmail -N -d0 -f $HOME/.fetchmailrc -m "/usr/bin/procmail $HOME/.procmailrc"

#
# ------------------------
# Create video
# save actual path of bash script
# act_path=$(pwd)
# to use as cron job
# act_path="/root/scripts"
# echo_log "actual path = [$act_path]"
# change path to OSM directory
#!!!! cd /root/scripts/OSM
#!!!! echo_log "osm: $(pwd)"
#!!!! /root/scripts/OSM/osmap.sh $LOGFILE
# return to bash script directory
#!!!! cd $act_path
# generate images for video (use max(id) config table)
./dbgenvideo.sh ./db/$fileis 0

# copy video and image
#
# change the permissions
# chmod -R 775 /root/scripts/OSM/video.mp4
# chmod -R 775 /root/scripts/docfiles/video_measures.png
#
# copy the files in the maps directory
#!!!! cp /root/scripts/OSM/video.mp4 /root/scripts/maps/$filename2/video.mp4
#!!!! cp /root/scripts/docfiles/video_measures.png /root/scripts/maps/$filename2/video_measures.png
cp ./video/$filename2/video.mp4 ./maps/$filename2/video.mp4
cp ./docfiles/video_measures.png ./maps/$filename2/video_measures.png
#
# scp -rp /root/scripts/OSM/video.mp4 mzennaro@140.105.28.91:/Volumes/ELEARNING/WIRELESS/wireless/tvws/$filename2
# scp -rp /root/scripts/docfiles/video_measures.png mzennaro@140.105.28.91:/Volumes/ELEARNING/WIRELESS/wireless/tvws/$filename2
# modify 12/10
#!!!! /root/scripts/cpydest.sh /root/scripts/maps/$filename2/video.mp4 /$filename2 $LOGFILE
#!!!! /root/scripts/cpydest.sh /root/scripts/maps/$filename2/video_measures.png /$filename2 $LOGFILE

# remove original db from dropbox
#!!!! rm /root/Dropbox/Apps/Attachments/$fileis

echo_log "end of work: [$fileis]"
# END OF SCRIPT
#
