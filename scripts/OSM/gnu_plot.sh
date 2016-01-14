#! /usr/bin/gnuplot 

reset
set term png truecolor
set output "graph.png"
set xlabel "Frequency (MHz)"
set ylabel "Signal Level (dBm)"
set yrange [-120:-60]
set autoscale xfix
set grid
set style fill transparent solid 0.5 noborder
plot "ready_for_graph.txt" u 1:2 with lines notitle 
set output
