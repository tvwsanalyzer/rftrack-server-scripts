#! /usr/bin/gnuplot 

reset
set term png truecolor
set output "OSM/graph_index_noise.png"
set xlabel "Measures"
set ylabel "Noise floor in dBm"
set yrange [-110:-60]
set autoscale xfix
set grid
set style fill transparent solid 0.5 noborder
set key right top 
plot "index_noise.txt" using 2 notitle with lines 
set output
