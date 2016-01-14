#!/bin/bash
# ------------------------------------------------------------

cp ../tmp/data_loc.txt ./data_locok.txt

length=$(cat data_locok.txt | wc -l)

for i in $(seq "$length");
do

head -n $i data_locok.txt | tail -1  > temp.txt

lat=$(cat temp.txt | awk -F"\t" '{print $1}')
lon=$(cat temp.txt | awk -F"\t" '{print $2}')

echo $lat $lon

./osmgnuplot --center $lat,$lon --rad 500m --zoom 14

mv montage_*.png image_$i.png
file image_$i.png
rm montage_*

#echo "attenuation = 1.5" > image.gp
#echo "set autoscale fix" >> image.gp
#echo "set output \"map_$i.png\"" >> image.gp
#echo "set terminal pngcairo enhanced color size 627,627 font \",10\""  >> image.gp

#echo "set title \"Map of measurement campaign\"" >> image.gp
#echo "set xlabel \"Longitude\""  >> image.gp
#echo "set ylabel \"Latitude\""  >> image.gp

#echo "set size ratio -1./cos(-25.975179735 * pi/180.0)" >> image.gp
#echo "plot \"image_$i.png\" binary filetype=png dx=8.58306884765625e-05 dy=7.7160402478979e-05 center=($lon,$lat) using (\$1/attenuation):(\$2/attenuation):(\$3/attenuation) with rgbimage notitle, '-' using 2:1 with points pt 7 ps 3 notitle" >> image.gp
#echo $lat $lon  >> image.gp
#echo "e"  >> image.gp
#echo "set output"  >> image.gp

#gnuplot -persist image.gp


done
