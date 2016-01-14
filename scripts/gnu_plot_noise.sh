#   #! /usr/bin/gnuplot 

reset
set datafile separator ";"					# separator from colums
# set term png truecolor
set term png truecolor size xdim,ydim
# set output "OSM/graph_index_noise.png"
set output foutput							# foutput: var with file name
set tics font ftype
set xlabel "Measures" font ftype
set ylabel "Noise floor in dBm\n\n" font ftype
set yrange [-130:-60]
set autoscale xfix
set grid
set style fill transparent solid 0.5 noborder
set key right top 
# plot "datafile" { using {<ycol> | <xcol>:<ycol> ..
# plot "index_noise.txt" using 2 notitle with lines 
plot data u 1:9 notitle with lines lw 2
set output
