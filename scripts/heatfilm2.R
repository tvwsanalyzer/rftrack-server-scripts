# -------------------------------------------------------------------------------
# Generate png for film2 with R
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
#
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
library(stringr)

# original code

# load the data
# original:
# tbl <- read.csv("data/tbl_xy_wgs84_a.csv", sep = ";")
# tst1:last column with random values
# ori
# tbl <- read.csv("tartu_mr_f.csv", sep = ";")
#
srcFile <- args[1]				# first parameter file with data
# destImg <- args[2]				# output image
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
#### bbox <- ggmap::make_bbox(tbl$lon, tbl$lat, f = 0.8)
#### 
#### mrz <- calc_zoom(bbox)
#### map_g_str <- get_map(
#### 					location = bbox,
#### 					zoom = mrz, 
#### #					zoom = 12, 
#### # 					source = "osm")
#### 					source = "google")
					
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

# http://stackoverflow.com/questions/25636897/get-map-with-specified-boundary-coordinates
# ex: location center.
# location = c(lon = mean(lon), lat = mean(lat))

for (i in 1:length(tbl$id)) {
# https://dzone.com/articles/learn-r-how-extract-rows
#stuff to do the number of times that foo is long

# original:
# perc_85:			
###  p <- ggmap(map_g_str) +
###  geom_point(aes(x = lon, y = lat, colour = perc_85), 
###  	data = tbl[1:i,],
###  	size = 2.5,
###  	lineend = "round",
###  	alpha = .5
###  	) +
###  	scale_colour_continuous(limits=c(50, 100), low  = "green", high = "red")

# http://www.r-bloggers.com/gps-basemaps-in-r-using-get_map/

map_g_str <- get_map(
# 					location = bbox,
					location = c(lon = tbl$lon[i], tbl$lat[i]),
#					location = c(lon = mean(lon), lat = mean(lat)),
#					zoom = mrz, 
#					zoom = 12, 
#					zoom = 16, 
					zoom = 18,
#					zoom = 17,
					force = "osm",
 					source = "osm"
#					source = "cloudmade"
#					source = "google",
#					maptype = "hybrid"
#					maptype = "roadmap"
					)

	# modify 15/11
# max_dBm:			
p <- ggmap(map_g_str) +
geom_point(aes(x = lon, y = lat, colour = max_dBm), 
#	data = tbl[1:i,],
	data = tbl[i,],
	size = 6,
 	color = "red",		## ok funziona
#	size = 8,
### 	color = "red",		## ok funziona
	lineend = "round",
	alpha = .9
###	)
	)
###	+ scale_colour_gradientn(limits=c(-120, -20), colours = rainbow(7))
	# scale_colour_continuous(limits=c(50, 100), low  = "green", high = "red")
	
	# ori: toString(i)
fname <- paste("./video/maps/",str_pad(i, 6, pad = "0"),"_map.png")
# fname <- paste("maps/png",toString(i),"_map.png")
fname <- str_replace_all(fname, " ", "")

png(filename=fname,width=600, height=600)
# print(p)
plot(p)
dev.off()
}


# dev.off()
# print(p)

###  # perc_90:			
###  p <- ggmap(map_g_str) +
###  geom_point(aes(x = lon, y = lat, colour = perc_90), 
###  	data = tbl,
###  	size = 2.5,
###  	lineend = "round",
###  	alpha = .5
###  	) +
###  	scale_colour_continuous(low  = "green", high = "red")
###  png(filename="perc_90.png",width=600, height=600)
###  print(p)
###  # dev.off()
###  # print(p)
###  
###  # perc_95:			
###  p <- ggmap(map_g_str) +
###  geom_point(aes(x = lon, y = lat, colour = perc_95), 
###  	data = tbl,
###  	size = 2.5,
###  	lineend = "round",
###  	alpha = .5
###  	) +
###  	scale_colour_continuous(low  = "green", high = "red")
###  png(filename="perc_95.png",width=600, height=600)
###  print(p)
###  # dev.off()
###  # print(p)
###  
###  # perc_100:			
###  p <- ggmap(map_g_str) +
###  geom_point(aes(x = lon, y = lat, colour = perc_100), 
###  	data = tbl,
###  	size = 2.5,
###  	lineend = "round",
###  	alpha = .5
###  	) +
###  	scale_colour_continuous(low  = "green", high = "red")
###  png(filename="perc_100.png",width=600, height=600)
###  print(p)
###  # dev.off()
###  # print(p)
