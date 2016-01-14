#!/bin/bash
# ------------------------------------------------------------
# This script compile a c program for sqlite
# Author: Marco Rainone
# Ver. 1.2, 2015/10/20
#
if [ "$#" -ne 2 ]; then
    echo "--------------------------------------------------------------------------------------"
    echo "Illegal number of parameters"
	echo "This script join two images."
    echo "Use: $0 <dest> <max number>"
	echo "example:"
	echo "$0 dest 100"
	echo "join 100 images and store in dest dir"
    echo "--------------------------------------------------------------------------------------"
	echo ""
	exit 1
fi

# http://superuser.com/questions/316132/appending-images-horizontally-in-imagemagick
for i in $(seq "$2"); 
do
# create the sort id for file name
sort_id=$( printf "%06d" $i )

# montage -geometry 480 "./graphs/"$sort_id"_graph.png" "./maps/"$sort_id"_map.png" "./total/"$sort_id"_frame.png"
# montage -geometry 600 "./graphs/"$sort_id"_graph.png" "./maps/"$sort_id"_map.png" "./total/"$sort_id"_frame.png"
montage -geometry 600 "./graphs/"$sort_id"_graph.png" "./maps/"$sort_id"_map.png" "./total/"$sort_id"_frame.png"

convert +append "./graphs/"$sort_id"_graph.png" "./maps/"$sort_id"_map.png" "./$1/"$sort_id"_frame.png"
done
