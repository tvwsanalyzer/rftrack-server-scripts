#!/bin/bash
# ------------------------------------------------------------
# This script get the placename from latitude, longitude
# see: http://www.geonames.org/export/web-services.html#findNearbyPlaceName
# http://stackoverflow.com/questions/3392160/converting-latitude-longitude-into-city-name-reverse-geolocating
# Author: Marco Rainone
# Ver. 1.0, 2015/10/20
#
if [ "$#" -ne 2 ]; then
    echo "--------------------------------------------------------------------------------------"
    echo "Illegal number of parameters"
	echo "This script get placename from latitude longitude."
    echo "Use: $0 <lat> <long>"
	echo "example:"
	echo "$0 46.064817 13.240042"
    echo "--------------------------------------------------------------------------------------"
	echo ""
	exit 1
fi

# round function:
# input: <floating number> <n. digits> 
# http://askubuntu.com/questions/179898/how-to-round-decimals-using-bc-in-bash
# http://stackoverflow.com/questions/8848335/bin-bash-printf-does-not-work-with-other-lang-than-c
# LC_NUMERIC setting, bash follows when parsing arguments to printf.
LC_NUMERIC=C LC_COLLATE=C
round()
{
	echo $(printf %.$2f $(echo "scale=$2;(((10^$2)*$1)+0.5)/(10^$2)" | bc))
};

# echo [$1][$2]
# round 2 digits after comma
# the geonames.org call has a problem if the coordinate has more 2 digits after comma
lat=$(round $1 2)
long=$(round $2 2)
# echo [$lat][$long]

# example
# wget -O countrycode.txt "http://api.geonames.org/countryCode?lat=47.03&lng=10.2&username=demo"
#
# fn_countrycode="http://api.geonames.org/countryCode?lat="${lat}"&lng="${long}"&username=tvwsanalyzer"
# xml format
# fn_placename="http://api.geonames.org/findNearbyPlaceName?lat="${lat}"&lng="${long}"&username=tvwsanalyzer"
# json format
fn_placename="http://api.geonames.org/findNearbyPlaceNameJSON?lat="${lat}"&lng="${long}"&username=tvwsanalyzer"
# echo $fn_countrycode
#
# execute the reverse geocode
wget -O gpsplace.txt $fn_placename > /dev/null 2>&1
#
# end of script
