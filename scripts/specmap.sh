#### #! /usr/bin/gnuplot
# ------------------------------------------------------------
# This script creates the spectral map
# Input:
# data: file name with data
# xdim: x dimension
# ydim:  dimension
# ftype: font command
# foutput: file name output
# ------------------------------------------------------------
set pm3d map
set terminal png 
set title "\n"
set term png truecolor size xdim,ydim
# set label 1 "Location: `head -1 position.txt`\nFrom `head -1 start_time.txt` to `head -1 end_time.txt`" at graph 0.1,1.125 left
# set label 1 "From `head -1 tmp/start_time.txt` to `head -1 tmp/end_time.txt`" at graph 0.1,1.125 left
# set label 1 "From `head -c 19 tmp/start_time.txt` to `head -c 19 tmp/end_time.txt`" at graph 0.1,1.125 left font ftype
set title "From `head -c 19 tmp/start_time.txt` to `head -c 19 tmp/end_time.txt`" font ftype
set lmargin 5
set rmargin 5
set tmargin 5
set bmargin 5
# set output 'spectral-map.png'
set output foutput
set tics font ftype
set xlabel "Measurement number" font ftype
set ylabel "Frequency (MHz)\n" font ftype
set cblabel "\nRSSI (dBm)" font ftype
# set format y "%g %cMHz";
set autoscale yfix
set autoscale xfix

set style line 12 lc rgb "black" lt 0 lw 1
set grid front ls 12

splot data
# splot 'tmp/spec_map.txt'
set cbrange [0 to GPVAL_DATA_Z_MAX]
set xrange [GPVAL_DATA_X_MIN to GPVAL_DATA_X_MAX]
#set yrange [3.2 to 3.45]

set key left bottom Left title 'Legend' box 3
#unset key
replot
#unset output
