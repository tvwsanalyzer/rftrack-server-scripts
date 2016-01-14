#!/bin/bash
# ------------------------------------------------------------
# This script get the placename from latitude, longitude
# see: http://www.geonames.org/export/web-services.html#findNearbyPlaceName
# http://stackoverflow.com/questions/3392160/converting-latitude-longitude-into-city-name-reverse-geolocating
# Author: Marco Rainone
# Ver. 1.0, 2015/10/20
#
if [ "$#" -ne 1 ]; then
    echo "--------------------------------------------------------------------------------------"
    echo "Illegal number of parameters"
	echo "This script get placename variables."
    echo "Use: $0 <file with var>"
	echo "example:"
	echo "$0 gpsplace.txt"
    echo "--------------------------------------------------------------------------------------"
	echo ""
	exit 1
fi

strjson=$(cat $1)
echo $strjson
# convert string delimiter to '|' char
str=${strjson//'{"geonames":[{"'/''}
str=${str//'}]}'/''}
str=${str//'":"'/'|'}
str=${str//'":'/'|'}
str=${str//'","'/'|'}
str=${str//',"'/'|'}
str=${str//'",'/'|'}
str=${str//'"'/'|'}
echo $str
# http://stackoverflow.com/questions/10586153/split-string-into-an-array-in-bash
# split string in array
# Initialize the dataArray, to store the specific data value:
# "countryName","countryCode","toponymName","fclName","adminName1","fcodeName","population"
dataArray=("" "" "" "" "" "" "")
#
IFS='|' read -r -a array <<< "$str"
for index in "${!array[@]}"
do
    echo "$index ${array[index]}"

	case "${array[index]}" in
		"countryName"	)	dataArray[0]=${array[index+1]} ;;
		"countryCode"	)	dataArray[1]=${array[index+1]} ;;
		"toponymName"	)	dataArray[2]=${array[index+1]} ;;
		"fclName"		)	dataArray[3]=${array[index+1]} ;;
		"adminName1"	)	dataArray[4]=${array[index+1]} ;;
		"fcodeName"		)	dataArray[5]=${array[index+1]} ;;
		"population"	)	dataArray[6]=${array[index+1]} ;;
	esac      			#  end of case

done

echo "-----------------------"
for index in "${!dataArray[@]}"
do
    echo "$index ${dataArray[index]}"
done


#
# end of script
