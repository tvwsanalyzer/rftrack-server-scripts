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
# Generate perc graphs for 85dBm to 100dBm with R
# -------------------------------------------------------------------------------
# this script analyze gpsfreqdbm.txt and generate an heatmap
#
args<-commandArgs(TRUE)
#
# set working directory:
currdir <- try(system("pwd", intern = TRUE))
setwd(currdir)
#
# mr: disabled:
# install.packages("ggmap")
library(ggmap)

#
srcFile <- args[1]				# first parameter file with data
xdim <- as.integer(args[2])		# dim x graph in pixel
ydim <- as.integer(args[3])		# dim y graph in pixel

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
bbox <- ggmap::make_bbox(tbl$lon, tbl$lat, f = 0.5)
mrz <- calc_zoom(bbox)
mrz <- mrz - 1			# modify 27/11 per tutti i report

map_g_str <- get_map(
					location = bbox,
					zoom = mrz, 
					scale = "auto",
					source = "google")
					
#
# Draw the map

# perc_85:			
p <- ggmap(map_g_str) +
geom_point(aes(x = lon, y = lat, colour = perc_85), 
	data = tbl,
	size = 2.5,
	lineend = "round",
	alpha = .5
	) +
	labs(x = 'Longitude', y = 'Latitude') +
	ggtitle("Percentage of samples below -85 dBm threshold") +
	theme(plot.title = element_text(lineheight=0.8, size=20, face="bold")) +
	scale_colour_gradientn(limits=c(0, 100), colours = rainbow(15)) +
	

	# scale_color_hue()
	# scale_colour_continuous(low  = "green", high = "red")
png(filename="perc_85.png",width=xdim, height=ydim)
print(p)
dev.off()
# print(p)

# perc_90:			
p <- ggmap(map_g_str) +
geom_point(aes(x = lon, y = lat, colour = perc_90), 
	data = tbl,
	size = 2.5,
	lineend = "round",
	alpha = .5
	) +
	labs(x = 'Longitude', y = 'Latitude') +
	ggtitle("Percentage of samples below -90 dBm threshold") +
	theme(plot.title = element_text(lineheight=0.8, size=20, face="bold")) +
	scale_colour_gradientn(limits=c(0, 100), colours = rainbow(15))
	# scale_colour_gradientn(colours=c("#E5F5F9","#99D8C9","#2CA25F"))
	# scale_colour_continuous(low  = "green", high = "red")
png(filename="perc_90.png",width=xdim, height=ydim)
print(p)
dev.off()
# print(p)

# perc_95:			
p <- ggmap(map_g_str) +
geom_point(aes(x = lon, y = lat, colour = perc_95), 
	data = tbl,
	size = 2.5,
	lineend = "round",
	alpha = .5
	) +
	labs(x = 'Longitude', y = 'Latitude') +
	ggtitle("Percentage of samples below -95 dBm threshold") +
	theme(plot.title = element_text(lineheight=0.8, size=20, face="bold")) +
	scale_colour_gradientn(limits=c(0, 100), colours = rainbow(15))
	# scale_colour_gradientn(colours = rainbow(7))
	# scale_colour_continuous(low  = "green", high = "red")
png(filename="perc_95.png",width=xdim, height=ydim)
print(p)
dev.off()
# print(p)

# perc_100:			
p <- ggmap(map_g_str) +
geom_point(aes(x = lon, y = lat, colour = perc_100), 
	data = tbl,
	size = 2.5,
	lineend = "round",
	alpha = .5
	) +
	labs(x = 'Longitude', y = 'Latitude') +
	ggtitle("Percentage of samples below -100 dBm threshold") +
	theme(plot.title = element_text(lineheight=0.8, size=20, face="bold")) +
	scale_colour_gradientn(limits=c(0, 100), colours = rainbow(15))
	# scale_colour_brewer()
	# scale_colour_continuous(low  = "green", high = "red")
png(filename="perc_100.png",width=xdim, height=ydim)
print(p)
dev.off()
# print(p)
