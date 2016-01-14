#!/bin/bash
# ------------------------------------------------------------
# Script insert campaign info in dbindex database
#
# Author: Marco Rainone
# Ver. 1.0, 2015/10/20
#

# -------------------------------------
# http://stackoverflow.com/questions/9893667/is-there-a-way-to-write-a-bash-function-which-aborts-the-whole-execution-no-mat
# register the top level shell for the TERM signal to exit
trap "exit 1" TERM
export TOP_PID=$$
#
# full name of script
CMDFILE=$(realpath $0)
echo "[$CMDFILE]"
CMDPATH="${CMDFILE%/*}"			# path directory that store the script
#
# directory to store the correct database for further analisys
DBTESTDIR="${CMDPATH}/dbtest"
echo "[$DBTESTDIR]"
mkdir -p $DBTESTDIR				# create directory if not exist
#
# directory to archive correct database
DBSVDIR="${CMDPATH}/dbbkp"
echo "[$DBSVDIR]"
mkdir -p $DBSVDIR				# create directory if not exist
#
# directory to archive database with errors
ERRDIR="${CMDPATH}/dberr"
echo "[$ERRDIR]"
mkdir -p $ERRDIR				# create directory if not exist

# dbindex: contains info of database analyzed
dbindex="dbindex.db"			# name of database index

# -------------------------------------
# log function
function echo_log {
	local dtlog=$(date +%Y%m%d:%H:%M:%S)
    local msg="$dtlog $1"
	# echo $msg | tee -a "$LOGFILE"
	# echo $msg >>$LOGFILE
	printf '%s\n' "$msg" >>$LOGFILE
    # echo $(date +%Y%m%d:%H:%M:%S) "$1" | tee $LOGFILE
}

# -------------------------------------
# calc sha1 checksum. 
# example:
# sha1 "t.txt"
# invoke sha1() and store its result to $out variable
# out=$(sha1 ${dbinput})
function sha1() 
{
    local str
    local chksum
    str=$(sha1sum -b $1)		# get the sha1 checksum of file
	chksum=${str:0:40}			# substring of 40 char from left to right
    echo $chksum
}
 
# -------------------------------------
# verify sha1 code of file
# calling example:
#	if [ $(chksha1 ${dbinput} ${dbchksum}) -eq "1" ]; then
#		# different sha1. Do something
#	fi 
function chksha1()
{
    local chksum=$(sha1 $1)
	# chksum="ciao"				# dbg
	local result=1				# default: different sha1 checksum
	if [ "$chksum" == "$2" ]; then
		result=0				# sha1 Key is valid
	fi
	# result=1					# dbg
	echo $result				# return value in result
}

# -------------------------------------
# manager to save database
function dbsave {
	# create 7z archive
	7z a ${DBSVDIR}/${bkpfilename}.7z $dbinput $database $LOGFILE > /dev/null 2>&1
	# rename the database modified
	mv $database $DBTESTDIR/$dbfilename
	# remove data
	rm -rf $dbinput
	rm -rf $dbbackup
	rm -rf $LOGFILE
}

# -------------------------------------
# manager for error found in database
function exit_dberror {
	# create 7z archive
	7z a ${ERRDIR}/${bkpfilename}.7z $dbinput $database $LOGFILE > /dev/null 2>&1
	# remove data
	rm -rf $dbinput
	rm -rf $dbbackup
	rm -rf $database
	rm -rf $LOGFILE
	echo "Error. See $LOGFILE archived in $dbfilename.7z. Goodbye"
	kill -s TERM $TOP_PID
}

# -------------------------------------
# check if tables exist
# http://stackoverflow.com/questions/1601151/how-do-i-check-in-sqlite-whether-a-table-exists
#
# http://www.linuxjournal.com/content/return-values-bash-functions
# check if in a database the table exist and return the number of data rows
# $1=table name
# $2=variable that return the number of rows in table
function tblexist()
{
	local  __resultvar=$2
	local ris
	ris=$(sqlite3 $database "SELECT count(*) FROM sqlite_master WHERE type='table' AND name='$1';")
	if [ "$ris" == "0" ]; then
		echo_log "err: table [$1] not exist"
		exit_dberror
	fi
	#
	# count n. rows in table $1
	ris=$(sqlite3 $database "SELECT count(*) FROM $1;")
	if [ "$ris" == "0" ]; then
		echo_log "err: table [$1] with zero rows"
		exit_dberror
	fi
	eval $__resultvar="'$ris'"
}
#
# -------------------------------------
# get the table rows number
function tblrowscount()
{
	local  __resultvar=$2
	local ris
	#
	# count n. rows in table $1
	ris=$(sqlite3 $database "SELECT count(*) FROM $1;")
	if [ "$ris" == "0" ]; then
		echo_log "err: table [$1] with zero rows"
		exit_dberror
	fi
	eval $__resultvar="'$ris'"
}

# -----------------------------------------------------------------------
# SCRIPT MAIN
# -----------------------------------------------------------------------
#
if [ "$#" -ne 2 ]; then
    echo "--------------------------------------------------------------------------------------"
    echo "Illegal number of parameters"
	echo "This script insert campaign info in dbindex database"
    echo "Use: $0 <db name> <archive filename>"
	echo "example:"
	echo "$0 fes.db fes.zip"
    echo "--------------------------------------------------------------------------------------"
	echo ""
	exit 1
fi

# If sqlite3 is not installed exit 
if [[ -z $( type -p sqlite3 ) ]]; then echo -e "REQUIRED: sqlite3 -- NOT INSTALLED !";exit 1;fi
#

#
# analyze database name
# http://stackoverflow.com/questions/965053/extract-filename-and-extension-in-bash
dbinput=$(realpath $1)						# full name of database, with path
new_name=$(./fncorrect.sh ${dbinput})		# correct the filename, if there are spaces in name
rc=$?										# get return code
if [ $rc -eq 0 ]
then
	echo "The file exist. Name verified"
	dbinput=${new_name}
else
	# --------------------------
	# the db not exist, or error rename
	# --------------------------
	echo "Error: return code: [$rc]"
	#
	exit 1
fi
#
DATELOG=$(date '+%Y-%m-%d %H:%M:%S')			# date time of db elaboration
#
dbchksum=$(sha1 ${dbinput})						# calc sha1 chksum for database
echo "$dbinput sha1: [$dbchksum]"

if [ $(chksha1 ${dbinput} ${dbchksum}) -eq "1" ]; then
	# different sha1. Do something
	echo "DIFFERENT SHA1"
else
	echo "SHA1 verify ok"
fi 

# check if in dbindex there is a file recorded with the same sha1 checksum
# Check if database dbindex exists, if not, create it.
if [ -e "$dbindex" ];then
	echo ""
else
	echo "Database index does not exist - Creating now"
	sqlite3 $dbindex < dbidxcreate.sql
	echo "Database index created at $dbindex"
fi
# check if there is a file recorded with the same sha1 checksum
ris=$(sqlite3 $dbindex "SELECT count(*) FROM dbcampaign WHERE db_sha1='$dbchksum';")
if (( "$ris" > "0" ))
then
	echo "!!!! Db already analyzed. Saved a record with the same checksum: [$ris]"
	ErrMsg="db already analyzed."
	ErrCode=3								# 
	# remove data
	rm -rf $dbinput
	exit 1
fi
#
# analyze database name
dbpath="${dbinput%/*}"						# path of database
dbfilename="${dbinput##*/}"					# only filename with extension
dbbasename="${dbfilename%.*}"				# db file name without extension
dbext="${dbfilename:${#dbbasename} + 1}"	# extension of db name
dbbackup="${dbbasename}.sqlite"				# name of db backup
echo "[$dbinput][$dbfilename][$dbbasename][$dbext][$dbbackup]"
#
# name of backup archive
dtbkp=$(date +%Y%m%d%H%M%S)
bkpfilename="${dtbkp}_${dbbasename}"		# backup filename without extension
echo "bkp filename: [$dtbkp][$bkpfilename]"
#
# name of log file
LOGFILE="${dbbasename}.log"
#
# create a copy of input database
database="$(mktemp $DBTESTDIR/dbcheck.XXXXXXXX)"			# temp name of database copy
cp $dbinput $database						# database copy to analyze
# create log 
echo_log $dbfilename
echo_log $dbpath
# check if the file is a sqlite database
pattern="SQLite 3.x database"
ris=$(file -b $database | tail)
if [[ "$ris" == *${pattern}* ]]; then
	# "is a sqlite database"
	echo "[$ris]"
	# echo_log "$ris"
	echo_log "SQLite 3.x database, user version 1"
	# echo $ris >> $LOGFILE
else
	# "no sqlite database"
	echo_log "err: no SQLite 3.x database"
	exit_dberror
fi
# =======================================================
# check the integrity
ris=$(sqlite3 $database "pragma integrity_check;")
echo_log "Db integrity check: [$ris]"
#
# check if tables exist and count the rows
echo "----------- start check tables:"
tblexist "android_metadata" nelem
echo_log "android_metadata: $nelem"
tblexist "campaign" nelem
echo_log "campaign: $nelem"
tblexist "config" nelem
echo_log "config: $nelem"
tblexist "dbmdata" nelem
echo_log "dbmdata: $nelem"
tblexist "location" nelem
echo_log "location: $nelem"
tblexist "maxdbm" nelem
echo_log "maxdbm: $nelem"
# table that not exist (for debug)
# tblexist $database "testnonesiste" nelem
#
# =======================================================
# check if there are duplicate config parameters
#
# http://stackoverflow.com/questions/54418/how-do-i-or-can-i-select-distinct-on-multiple-columns
# http://stackoverflow.com/questions/21980064/find-duplicate-column-value-in-sqlite
# get rows with duplicate column in config table and store it in dup.log
sqlite3 $database "SELECT campaign_id,start_freq,end_freq,amp_top,amp_bottom, COUNT(*) c FROM config GROUP BY campaign_id,start_freq,end_freq,amp_top,amp_bottom HAVING c > 1;" > dup.log
# http://stackoverflow.com/questions/11393817/bash-read-lines-in-file-into-an-array
while IFS=$'|' read -r -a myArray
do
	# get each field of a row
	echo "${myArray[0]}"
	echo "${myArray[1]}"
	echo "${myArray[2]}"
	echo "${myArray[3]}"
	echo "${myArray[4]}"
	echo "${myArray[5]}"
	echo "get config row with same id..."
	#
	rm -rf listid.log
	sqlite3 $database "SELECT id FROM config WHERE start_freq=${myArray[1]} AND end_freq=${myArray[2]} AND amp_top=${myArray[3]} AND amp_bottom=${myArray[4]};" > listid.log
	read -r FIRSTID < listid.log
	echo "First id: $FIRSTID"
	while read -r OTHERID
	do
		if [ "$OTHERID" == "$FIRSTID" ]; then
			echo "first id!!!"
			continue
		fi
		# substitute OTHERID with FIRSID in dbmdata
		echo "Other id: $OTHERID"
		name=$OTHERID
		echo "Name read from file - $name"
		sqlite3 $database "UPDATE dbmdata SET config_id=${FIRSTID} WHERE config_id=${OTHERID};"
		# in config table, remove row with id=OTHERID
		sqlite3 $database "DELETE FROM config WHERE id=${OTHERID};"
	done < listid.log
	echo "------------------"
done < dup.log

# =======================================================
# get rows from location with latitude, longitude position equal 0.0. Store it in nogps.log
ris=$(sqlite3 $database "SELECT count(*) FROM location WHERE latitude='0.0' AND longitude='0.0';")
if [ "$ris" != "0" ]; then
	# there are locations with (latitude, longitude) equals (0.0, 0.0)
	echo "N. rows of location row with coordinate 0: $ris"
	echo_log "N. rows of location row with coordinate 0: $ris"
	sqlite3 $database "SELECT id,latitude,longitude FROM location GROUP BY id,latitude,longitude HAVING latitude='0.0' AND longitude='0.0';" > nogps.log
	# clean rows with referring to position 0
	while IFS=$'|' read -r -a myArray
	do
		# get each field of a row
		echo "${myArray[0]}"
		echo "${myArray[1]}"
		echo "${myArray[2]}"
		#
		# remove all location elements with coordinate 0
		#
		sqlite3 $database "DELETE FROM location WHERE id=${myArray[0]};"
		# remove all dbmdata rows referring to coordinate 0
		sqlite3 $database "DELETE FROM dbmdata WHERE location_id=${myArray[0]};"
		echo "------------------"
	done < nogps.log
	# verify if after correction the tables are empty
	tblrowscount "location" nelem
	echo_log "location: $nelem"
	tblrowscount "dbmdata" nelem
	echo_log "dbmdata: $nelem"
fi

#
# all gps position OK


# get info from db
sqlite3 $database < gpsfreq.sql

cnt=$(head count.txt)					# get the number of nuple (pos)(instrument readings)
if (( $(echo "$cnt == 0" |bc -l) ))
then
echo "$database does not have rosw."; echo
	ErrMsg="db does not have rosw."
	ErrCode=4							# 
	exit_dberror               			# exit for error found on db.
fi

#-----------------------------------------------------------
# The db has data
# Get the coordinate limits
#
start_time=$(cat start_time.txt)
max_lat=$(head max_latitude.txt)
max_lon=$(head max_longitude.txt)
min_lat=$(head min_latitude.txt)
min_lon=$(head min_longitude.txt)

# calc the coordinate of middle point
mid_lat=$(bc -l <<< "($max_lat + $min_lat) / 2.0")
mid_lon=$(bc -l <<< "($max_lon + $min_lon) / 2.0")

#-----------------------------------------------------------
# calc the route length
# dist=$(./distroute.sh ${dbinput} 1000.0)
dist="0.0"					# dbg

#-----------------------------------------------------------
# get the reverse geocode for campaign position
# disabled countrycode (obsolete). Use placename.sh
# ./countrycode.sh $max_lat $max_lon
# echo "ZZ" > ccode.txt						# dbg
# get only the two char of country
# country=$(head -c2 ccode.txt)				# dbg
#
# ./placename.sh $max_lat $max_lon
./placename.sh $mid_lat $mid_lon
#
# analyze the output file gpsplace.txt
strjson=$(cat ./gpsplace.txt)
# echo $strjson								# dbg
# convert string delimiter to '|' char
str=${strjson//'{"geonames":[{"'/''}
str=${str//'}]}'/''}
str=${str//'":"'/'|'}
str=${str//'":'/'|'}
str=${str//'","'/'|'}
str=${str//',"'/'|'}
str=${str//'",'/'|'}
str=${str//'"'/'|'}
# echo $str									# dbg
# http://stackoverflow.com/questions/10586153/split-string-into-an-array-in-bash
# split string in array
# Initialize the dataArray, to store the specific data value:
# "countryName","countryCode","toponymName","fclName","adminName1","fcodeName","population"
dataArray=("" "" "" "" "" "" "")
#
IFS='|' read -r -a array <<< "$str"
for index in "${!array[@]}"
do
	# echo "$index ${array[index]}"			# dbg

	case "${array[index]}" in
		"countryName"	)	dataArray[0]=${array[index+1]} ;;
		"countryCode"	)	dataArray[1]=${array[index+1]} ;;
		"toponymName"	)	dataArray[2]=${array[index+1]} ;;
		"fclName"		)	dataArray[3]=${array[index+1]} ;;
		"adminName1"	)	dataArray[4]=${array[index+1]} ;;
		"fcodeName"		)	dataArray[5]=${array[index+1]} ;;
		"population"	)	dataArray[6]=${array[index+1]} ;;
	esac      			#  end of case

	# --------------------------------------
	# correction for toponomy Errors
	if [ "${dataArray[1]}" = "IT" ]
	then
		if [ "${dataArray[2]}" = "Dolenja Vas" ]
		then
			dataArray[2]="Trieste, ICTP - International Centre For Theoretical Physics"
		fi
	fi
	# --------------------------------------
	
done
# dbg
# echo "-----------------------"
# for index in "${!dataArray[@]}"
# do
# 	echo "$index ${dataArray[index]}"
# done
#-------------------------
# country="IT"

# the db has passed all tests
ErrMsg="OK"
ErrCode="0"							# err=0 : no error

dbsave								# save the database verified
bkpchksum=$(sha1 ${DBSVDIR}/${bkpfilename}.7z)		# calc sha1 chksum for archive

# create a new record with the db info
#
# there is an autoincrement for index id. The alias is ROWID
# see: http://stackoverflow.com/questions/7905859/is-there-an-auto-increment-in-sqlite
sqlite3 $dbindex \
	"insert into dbcampaign \
	(date,db_name,db_sha1,\
	bk_name,bk_sha1,\
	error,\
	errcode,\
	lenRoute,\
	min_latitude,min_longitude,\
	max_latitude,max_longitude,\
	created_at,\
	countryName,\
	countryCode,\
	toponymName,\
	fclName,\
	adminName1,\
	fcodeName,\
	population\
	) \
	values \
	('$DATELOG','$dbbasename','$dbchksum',\
	'$bkpfilename','$bkpchksum',\
	'$ErrMsg',\
	'$ErrCode',\
	'$dist',\
	'$min_lat','$min_lon',\
	'$max_lat','$max_lon',\
	'$start_time',\
	'${dataArray[0]}',\
	'${dataArray[1]}',\
	'${dataArray[2]}',\
	'${dataArray[3]}',\
	'${dataArray[4]}',\
	'${dataArray[5]}',\
	'${dataArray[6]}'\
	);"

exit 0

# -----------------------------------------------------------------------
# end of script
