# -------------------------------------------------------------------------------
# Generate perc graphs for 85dBm to 100dBm with R
# -------------------------------------------------------------------------------
# this script analyze gpsfreqdbm.txt and generate an heatmap
# 
# Package source URL: http://cran.r-project.org/web/packages/ggmap/ggmap.pdf
# Data source URL: http://www.geo.ut.ee/aasa/LOOM02331/heatmap_in_R.html
# run: source("/home/marco/Documenti/bkp_rftrack/R-tests/mrggmapg/mrggmaph.R")
#
# ------------------------------------------
# see: http://stackoverflow.com/questions/2151212/how-can-i-read-command-line-parameters-from-an-r-script
# read command line arguments
# Add this to the top of your script:
# args<-commandArgs(TRUE)
# Then you can refer to the arguments passed as args[1], args[2] etc.
# Then run
# Rscript myscript.R arg1 arg2 arg3
# If your args are strings with spaces in them, enclose within double quotes.
# ------------------------------------------
# 
args<-commandArgs(TRUE)
# set working directory:
# http://stackoverflow.com/questions/13672720/r-command-for-setting-working-directory-to-source-file-location
currdir <- try(system("pwd", intern = TRUE))
setwd(currdir)
# mr: working directory:
# setwd("/home/marco/Documenti/bkp_rftrack/sqlite_c/")
#
# mr: disabled:
# install.packages("ggmap")
library(ggmap)

# original code

# load the data
# original:
# tbl <- read.csv("data/tbl_xy_wgs84_a.csv", sep = ";")
# tst1:last column with random values
# ori
# tbl <- read.csv("tartu_mr_f.csv", sep = ";")
#
srcFile <- args[1]				# first parameter file with data
xdim <- as.integer(args[2])		# dim x graph in pixel
ydim <- as.integer(args[3])		# dim y graph in pixel
pdim <- as.integer(args[4])		# dim of point
mType <- args[5]				# map type
nCol <- args[6]					# n. col
destImg <- args[7]				# output image
#
# read the file csv without header.
# in this case, tbl$V1 is the first column, tbl$V2 the second, ...
tbl <- read.csv(srcFile, sep = ";")
# tbl <- read.csv(srcFile, sep = ";", header=FALSE)
# tbl <- read.csv(srcFile, sep = "|")

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
# http://stackoverflow.com/questions/11056738/plotting-points-from-a-data-frame-using-openstreetmap
# http://stackoverflow.com/questions/24661321/plotting-openstreetmap-with-ggmap
# 
# get map from google maps
# map_g_str <- get_map(location = "tartu", zoom = 13)
# map_g_str <- get_map(location = "tartu", zoom = 12)
#
# get map from openstreetmap
# map_g_str <- get_map(location = "tartu", zoom = 12, source = "osm")
# http://www.inside-r.org/packages/cran/ggmap/docs/get_map
# variant: use the coordinate:
# map_g_str <- get_map(location = c(58.3744893,26.7318107), zoom = 12, source = "osm")
# http://stackoverflow.com/questions/22335893/get-map-does-not-download-full-extent-of-map-wanted
# http://finzi.psych.upenn.edu/library/ggmap/html/make_bbox.html
# bbox <- ggmap::make_bbox(lon, lat, data=tbl, f = 0.5)

# ======
# lon <- mean(tbl$lon)
# lat <- mean(tbl$lat)
# map_g_str <- get_map(
# 					location = c(lon , lat),
# 					zoom = 12, 
# #					source = "osm")
# 					source = "google")
# ======

# funziona!!!!
# bbox <- ggmap::make_bbox(tbl$lon, tbl$lat, f = 0.5)
bbox <- ggmap::make_bbox(tbl$lon, tbl$lat, f = 0.5)
mrz <- calc_zoom(bbox)
# mrz <- min(MaxZoom(range(tbl$lat), range(tbl$lon)))
mrz <- mrz - 1
# From range
# lon_range <- extendrange( tbl$lon )
# lat_range <- extendrange( tbl$lat )
# mrz <- calc_zoom(lon_range, lat_range)
# http://www.r-bloggers.com/gps-basemaps-in-r-using-get_map/
map_g_str <- get_map(
					location = c(lon = mean(tbl$lon), lat = mean(tbl$lat)), 
					# location = bbox,
					zoom = mrz, 
					scale = "auto",
#					zoom = 12, 
# 					source = "osm")
					source = "google",
					maptype = "hybrid"
					)
					
# map_g_str <- get_map(
# 		location = c(left = min(tbl$lat), bottom = min(tbl$lon), 
# 					right =max(tbl$lat) , top = max(tbl$lon)),
# 					zoom = 12, 
# 					source = "google")
#					source = "osm")
#
# Draw the heat map
# ori
# p <- ggmap(map_g_str, extent = "device") + geom_density2d(data = tbl, aes(x = lon, y = lat), size = 0.3) + 
#   stat_density2d(data = tbl, 
#                  aes(x = lon, y = lat, fill = ..level.., alpha = ..level..), 
# 				 size = 0.01, 
#                  bins = 16, geom = "polygon") + 
# 				 scale_fill_gradient(low = "green", high = "red") + 
#   scale_alpha(range = c(0, 0.3), guide = FALSE)
#
# modifiche basate queste info: 
# http://stackoverflow.com/questions/18285415/density2d-plot-using-another-variable-for-the-fill-similar-to-geom-tile
# http://www.hitmaroc.net/2297931-1359-transparency-alpha-levels-ggplot2-stat-density2d-maps-layers.html
# http://gis.stackexchange.com/users/6328/slowlearner
# http://vietletruc.com/spatial-heat-map-r/
# http://stackoverflow.com/questions/22739076/heatmap-in-r-w-gradient
#
# Draw the map

# perc_85:			
p <- ggmap(map_g_str) +
geom_point(aes(x = lon, y = lat, colour = perc_85), 
	data = tbl,
#	size = 2.5,
	size = 4,
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
