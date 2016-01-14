#   #! /usr/bin/gnuplot 

reset
set datafile separator ";"					# separator from colums
# set term png truecolor
set term png truecolor size xdim,ydim
# set output "OSM/graph_index_perc.png"
set output foutput							# foutput: var with file name
set tics font ftype
set xlabel "Measures" font ftype
set ylabel "Percentage of measurements below threshold value\n" font ftype
set yrange [0:100]
set autoscale xfix
set grid
set style fill transparent solid 0.5 noborder
set key left bottom 
# plot "datafile" { using {<ycol> | <xcol>:<ycol> ..
# plot "index_perc.txt" using 2 title '-85 dBm' with lines, "index_perc.txt" using 3 title '-90 dBm' with lines, "index_perc.txt" using 4 title '-95 dBm' with lines, "index_perc.txt" using 5 title '-100 dBm' with lines 
# plot data u 1:4 title '-85 dBm' with lines lw 2, data 1:5 title '-90 dBm' with lines lw 2, data 1:6 title '-95 dBm' with lines lw 2, data 1:7 title '-100 dBm' with lines lw 2 
# plot data u 1:4 title '-85 dBm' with lines, data u 1:5 title '-90 dBm' with lines, data u 1:6 title '-95 dBm' with lines, data u 1:7 title '-100 dBm' with lines 
plot data u 1:4 title '-85 dBm' with lines lw 2, data u 1:5 title '-90 dBm' with lines lw 2, data u 1:6 title '-95 dBm' with lines lw 2, data u 1:7 title '-100 dBm' with lines lw 2 
set output
