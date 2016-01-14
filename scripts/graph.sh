#! /usr/bin/gnuplot 
#load "histograms.dem"

reset
set term png truecolor
set output "histogram_85.png"
set xlabel "Frequency (MHz)"
set ylabel "Percentage of Measurements \nbelow -85 dBm"
set autoscale yfix
set autoscale xfix
set grid
set boxwidth 0.95 relative
set style fill transparent solid 0.5 noborder
plot "./tmp/graph.txt" u 1:2 w boxes lc rgb"green" notitle


reset
set term png truecolor
set output "histogram_90.png"
set xlabel "Frequency (MHz)"
set ylabel "Percentage of Measurements \nbelow -90 dBm"
set autoscale yfix
set autoscale xfix
set grid
set boxwidth 0.95 relative
set style fill transparent solid 0.5 noborder
plot "./tmp/graph.txt" u 1:3 w boxes lc rgb"green" notitle


reset
set term png truecolor
set output "histogram_95.png"
set xlabel "Frequency (MHz)"
set ylabel "Percentage of Measurements \nbelow -95 dBm"
set autoscale yfix
set autoscale xfix
set grid
set boxwidth 0.95 relative
set style fill transparent solid 0.5 noborder
plot "./tmp/graph.txt" u 1:4 w boxes lc rgb"green" notitle


reset
set term png truecolor
set output "histogram_100.png"
set xlabel "Frequency (MHz)"
set ylabel "Percentage of Measurements \nbelow -100 dBm"
set autoscale yfix
set autoscale xfix
set grid
set boxwidth 0.95 relative
set style fill transparent solid 0.5 noborder
plot "./tmp/graph.txt" u 1:5 w boxes lc rgb"green" notitle
