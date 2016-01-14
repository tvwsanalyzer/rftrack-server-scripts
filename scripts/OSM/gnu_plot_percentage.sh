#! /usr/bin/gnuplot 

reset
set term png truecolor
set output "OSM/graph_index_perc.png"
set xlabel "Measures"
set ylabel "Percentage of measurements below threshold value"
set yrange [0:100]
set autoscale xfix
set grid
set style fill transparent solid 0.5 noborder
set key left bottom 
plot "index_perc.txt" using 2 title '-85 dBm' with lines, "index_perc.txt" using 3 title '-90 dBm' with lines, "index_perc.txt" using 4 title '-95 dBm' with lines, "index_perc.txt" using 5 title '-100 dBm' with lines 
set output
