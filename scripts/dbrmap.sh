#!/bin/bash
# ------------------------------------------------------------
# This script generate percentual dBm graphs with R 
#
# ----------------------------------------------------------------------------
#if [ "$#" -ne 2 ]; then
#    echo "--------------------------------------------------------------------------------------"
#    echo "Illegal number of parameters"
#	echo "This script create 85dBm to 100dBm graphs analyzing a RfTrack db."
#    echo "Use: $0 <db_name> <config id>"
#	echo "example:"
#	echo "$0 fes.db 1"
#	echo "Generate graphs fes.db with config id 1"
#    echo "--------------------------------------------------------------------------------------"
#	echo ""
#	exit 1
#fi

# ./dban $1 $2 -N > perc.txt

# create the perc_85..perc_100 graphs
# Rscript rmap.R perc.txt 600 600
# http://www.r-bloggers.com/gps-basemaps-in-r-using-get_map/
# map type: terrain, satellite, roadmap, hybrid, 
Rscript rmap.R perc.txt 600 600 3.5 hybrid maproute.png
# hi res
Rscript rmap.R perc.txt 1200 1200 5 hybrid maproute-hires.png
