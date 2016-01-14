#!/usr/bin/gnuplot

# Should adjust this based on data range
set xtics .02 

set xlabel "Longitude"
set ylabel "Latitude"
set key left bottom
#set xrange [-117.25:-117.15]
set terminal svg enhanced size 1024 768 

set object 1 rect from screen 0,0,0 to screen 1,1,0 behind
set object 1 rect fc rgb "white" fillstyle solid 1.0

# Data is comma delimited
#set datafile separator ","

# PakTrakr remote "A"
set title "GPS Track"

# Color based on amps. Green is less, red is more.
#ampcolor(a) = (a <= 300 ? (int((a)*(255./300.))*65536)+(255*256) \
#              : (255*65536)+(int((600-a)*(255./300.))*256))

ampcolor(a) = (a <= 100 ? (int((a)*(255./100.))*65536)+(255*256) \
              : (255*65536)+(int((100-a)*(255./100.))*256))

# Color based on speed. Green is faster, red is slower.
speedcolor(a) = (a <= 40 ? (255*65536)+(int(a*(255./40.))*256) \
                : (int((80-a)*(255./40.))*65536)+(255*256))

# Circle size based on amps. Make a small circle if the amps are very low.
ampradius(a) = (a < 50. ? 50./300000. : a / 300000.)

set output "gps_line.svg"
#plot "gps_perc.txt" using 1:2:(ampcolor(300)) title "GPS" with lines lw 8 \
#    lc rgb variable

# set this to the range of your variable which you want to color-encode
# or leave it out
#set cbrange [0:100]

# define the palette to your liking
#set palette defined ( 0 "#B0B0B0", 20 "#FF0000", 60 "#0000FF", 100 "#000000" )

#plot "gps_perc.txt" using 1:2:(ampcolor($3)) title "GPS" with lines lw 8 \
    lc rgb variable


plot "gps_perc.txt" using 1:2:3 w l lw 8 lc palette

