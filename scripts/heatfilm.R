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
# -------------------------------------------------------------------------------
# Script R to generate maps as part of film frames
# -------------------------------------------------------------------------------
# 
# read command line arguments
args<-commandArgs(TRUE)
#
# set working directory:
currdir <- try(system("pwd", intern = TRUE))
setwd(currdir)
#
# mr: disabled:
# install.packages("ggmap")
library(ggmap)
library(stringr)

# load the data
#
srcFile <- args[1]				# first parameter file with data
#
# read the file csv without header.
# in this case, tbl$V1 is the first column, tbl$V2 the second, ...
tbl <- read.csv(srcFile, sep = ";")

# the format for the file is:
# tbl$V1 = id number
# tbl$V2 = latitude
# tbl$V3 = longitude
# tbl$V4 = perc 85
# tbl$V5 = perc 90
# tbl$V6 = perc 95
# tbl$V7 = perc 100

# Download the base map
# 
# bbox <- ggmap::make_bbox(tbl$lon, tbl$lat, f = 0.5)
bbox <- ggmap::make_bbox(tbl$lon, tbl$lat, f = 0.8)

mrz <- calc_zoom(bbox)
map_g_str <- get_map(
					location = bbox,
					zoom = mrz, 
#					zoom = 12, 
# 					source = "osm")
					source = "google")
					
#
# Draw the map

for (i in 1:length(tbl$id)) {

# max_dBm:			
p <- ggmap(map_g_str) +
geom_point(aes(x = lon, y = lat, colour = max_dBm), 
	data = tbl[1:i,],
	size = 2.5,
	lineend = "round",
	alpha = .5
	) +
	scale_colour_gradientn(limits=c(-120, -20), colours = rainbow(7))
	# scale_colour_continuous(limits=c(50, 100), low  = "green", high = "red")
	
	# ori: toString(i)
# modify for cron: set full path
fname <- currdir
fname <- paste(fname, "/video/maps/")
fname <- paste(fname,str_pad(i, 6, pad = "0"),"_map.png")

# original: set relative path
# fname <- paste("./video/maps/",str_pad(i, 6, pad = "0"),"_map.png")

fname <- str_replace_all(fname, " ", "")

png(filename=fname,width=600, height=600)
plot(p)
dev.off()
}

