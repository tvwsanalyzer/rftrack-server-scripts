#!/bin/bash

cp ../tmp/gpsfreqdbm.txt data.txt
length=$(tail -2 data.txt | head -1 | awk -F"\t" '{print $1}')

# ----------------------------------------------------------------------------
# ANALYSIS CYCLE
#
for i in $(seq "$length"); 
do

head -n 112 data.txt > temp.txt
head -n 1 temp.txt > temp_gps.txt

lat=$(awk -F"\t" '{print $2}' temp_gps.txt) 
lon=$(awk -F"\t" '{print $3}' temp_gps.txt)

# echo $i $lat $lon

head -n 111 temp.txt > temp_db.txt

awk -F"\t" '{print $5}' temp_db.txt > ready.txt

counter_85=0
counter_90=0
counter_95=0
counter_100=0

while read -r line
do
    name=$line
    if [ "$line" -lt "-85" ]; then
    counter_85=$((counter_85+1))    
    fi
    if [ "$line" -lt "-90" ]; then
    counter_90=$((counter_90+1))
    fi
    if [ "$line" -lt "-95" ]; then
    counter_95=$((counter_95+1))
    fi
    if [ "$line" -lt "-100" ]; then
    counter_100=$((counter_100+1))
    fi

done < "ready.txt"

min=$(cut -f1 -d" " ready.txt | sort -n | head -1)

percentage_85=$((counter_85*100/113))
percentage_90=$((counter_90*100/113))
percentage_95=$((counter_95*100/113))
percentage_100=$((counter_100*100/113))


echo $lat $lon $percentage >> gps_perc.txt

echo $i $percentage_85 $percentage_90 $percentage_95 $percentage_100 >> index_perc.txt

echo $i $min >> index_noise.txt 

echo $lat $lon $percentage_85 $percentage_90 $percentage_95 $percentage_100 >> gps_perc_R.txt

tail -n +113 data.txt > temp.txt 
mv temp.txt data.txt
rm temp_gps.txt
rm temp_db.txt
rm ready.txt


done


./gnu_plot_percentage.sh

./gnu_plot_noise.sh

rm gps_perc.txt
rm index_perc.txt
rm index_noise.txt


# ----------------------------------------------------------------------------
#

