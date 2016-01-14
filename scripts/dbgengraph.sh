#!/bin/bash
# ========================================================================
# Copyright (c) 2014-2016
# - Wireless T/ICT4D Lab (http://wireless.ictp.it/) &
# - Marco Rainone (https://www.linkedin.com/in/marcorainone)
# This file is part of project RfTrack - White Space Analyzer.
# This is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
# ========================================================================
#
# ------------------------------------------------------------
# This script generate percentual dBm graphs calling script gnuplot and R 
#
# ----------------------------------------------------------------------------
if [ "$#" -ne 2 ]; then
    echo "--------------------------------------------------------------------------------------"
    echo "Illegal number of parameters"
	echo "This script create 85dBm to 100dBm graphs analyzing a RfTrack db."
    echo "Use: $0 <db_name> <config id>"
	echo "example:"
	echo "$0 fes.db 1"
	echo "Generate graphs fes.db with config id 1"
    echo "--------------------------------------------------------------------------------------"
	echo ""
	exit 1
fi

./dban $1 $2 -N perc.txt

# create the histogram_85..histogram_100

# substitute of graph.sh:
data="./tmp/graph.txt"
xdim=800			
ydim=600
ftype="sans Bold, 14"
# graph -85 dBm
ylab="Percentage of Measurements below -85 dBm"
ycol=2
foutput="histogram_85.png"
gnuplot -e "data='${data}'; ylab='${ylab}'; xdim='${xdim}'; ydim='${ydim}'; ftype='${ftype}';ycol=${ycol}; foutput='${foutput}'" grpbelow.sh
# graph -90 dBm
ylab="Percentage of Measurements below -90 dBm"
ycol=3
foutput="histogram_90.png"
gnuplot -e "data='${data}'; ylab='${ylab}'; xdim='${xdim}'; ydim='${ydim}'; ftype='${ftype}';ycol=${ycol}; foutput='${foutput}'" grpbelow.sh
# graph -95 dBm
ylab="Percentage of Measurements below -95 dBm"
ycol=4
foutput="histogram_95.png"
gnuplot -e "data='${data}'; ylab='${ylab}'; xdim='${xdim}'; ydim='${ydim}'; ftype='${ftype}';ycol=${ycol}; foutput='${foutput}'" grpbelow.sh
# graph -100 dBm
ylab="Percentage of Measurements below -100 dBm"
ycol=5
foutput="histogram_100.png"
gnuplot -e "data='${data}'; ylab='${ylab}'; xdim='${xdim}'; ydim='${ydim}'; ftype='${ftype}';ycol=${ycol}; foutput='${foutput}'" grpbelow.sh

# create the percentage graph below limits
data="perc.txt"
xdim=800			
ydim=600
ftype="sans Bold, 14"
foutput="graph_index_perc.png"
gnuplot -e "data='${data}'; xdim='${xdim}'; ydim='${ydim}'; ftype='${ftype}'; foutput='${foutput}'" gnu_plot_percentage.sh

# create the percentage graph below limits HI-RES
data="perc.txt"
xdim=3200			
ydim=2400
ftype="sans Bold, 28"
foutput="graph_index_perc-hires.png"
gnuplot -e "data='${data}'; xdim='${xdim}'; ydim='${ydim}'; ftype='${ftype}'; foutput='${foutput}'" gnu_plot_percentage.sh

# create the noise floor graph
data="perc.txt"
xdim=800
ydim=600
ftype="sans Bold, 14"
foutput="graph_index_noise.png"
gnuplot -e "data='${data}'; xdim='${xdim}'; ydim='${ydim}'; ftype='${ftype}'; foutput='${foutput}'" gnu_plot_noise.sh

# create the noise floor graph HI-RES
data="perc.txt"
xdim=3200
ydim=2400
ftype="sans Bold, 28"
foutput="graph_index_noise-hires.png"
gnuplot -e "data='${data}'; xdim='${xdim}'; ydim='${ydim}'; ftype='${ftype}'; foutput='${foutput}'" gnu_plot_noise.sh

# -------------------------------
# R script:
# 1) create the perc_85..perc_100 graphs
Rscript perc_85_100.R perc.txt 600 600
#
# map type: terrain, satellite, roadmap, hybrid, 
# base map
Rscript rmap.R perc.txt 600 600 3.5 hybrid maproute.png
# hi res map
Rscript rmap.R perc.txt 1200 1200 5 hybrid maproute-hires.png
#
# -------------------------------

# create the spectral map low res
data="./tmp/spec_map.txt"
xdim=800
ydim=600
ftype="sans Bold, 14"
foutput="spectral-map.png"
gnuplot -e "data='${data}'; xdim='${xdim}'; ydim='${ydim}'; ftype='${ftype}'; foutput='${foutput}'" specmap.sh

# create the spectral map hi res
data="./tmp/spec_map.txt"
xdim=3200
ydim=2400
ftype="sans Bold, 28"
foutput="spectral-map-hires.png"
gnuplot -e "data='${data}'; xdim='${xdim}'; ydim='${ydim}'; ftype='${ftype}'; foutput='${foutput}'" specmap.sh

# ./specmap.sh
 
# ----------------------------------------------------------------------------
#
echo "<<<--- End   [$0]"

