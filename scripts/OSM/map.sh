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
# This script generate image map with OSM
# ver. 1.1 01/01/2016
# ------------------------------------------------------------
#
lat="$1"
lon="$2"
# get the file output
# foutput="$3"
#
# maperitive_loc.dir has the full path of Maperitive library
# path_mape=$(head -n 1 maperitive_loc.dir)
# echo $path_mape
# save actual path of bash script
act_path=$(pwd)
path_mape=$act_path"/Maperitive"
# change path to Maperitive library
cd $path_mape
# ------------- Start generation of scri.mscript
echo "use-ruleset alias=default" > scri.mscript
echo "add-web-map" >> scri.mscript
echo "center-map x="$lon " y="$lat " zoom=17" >> scri.mscript
echo "move-pos x="$lon " y="$lat " zoom=17" >> scri.mscript
echo "set-setting name=map.decoration.grid value=false" >> scri.mscript
echo "set-setting name=map.decoration.scale value=true" >> scri.mscript
echo "set-setting name=map.decoration.attribution value=false" >> scri.mscript
echo "use-ruleset location=rules/GoogleMaps.mrules" >> scri.mscript
echo "apply-ruleset" >> scri.mscript
echo "export-bitmap file=output/img.png width=600 height=440" >> scri.mscript
# ------------- End generation of scri.mscript
# execute Maperitive script
# Maperitive/Mapconsole.sh scri.mscript > nul
mono --desktop Maperitive.Console.exe scri.mscript > nul
# with imagemagik, set a center point and add a 20x20 border
convert output/img.png -fill red -draw "circle 300,220 294,220" -bordercolor white -border 20x20 output/img.png
# return to bash script directory and save image_xx.png file
cd $act_path
# cp "$path_mape/output/img.png" ./maps/image_$out.png
# cp "$path_mape/output/img.png" $foutput


