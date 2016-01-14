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
# R script to generate mapworld
# -------------------------------------------------------------------------------
#
args<-commandArgs(TRUE)
#
# set working directory:
currdir <- try(system("pwd", intern = TRUE))
setwd(currdir)
#
library(stringr)

#Get the world map country border points
library(maps)
library(ggplot2)

# load the data
srcFile <- args[1]				# first parameter file with data
tbl <- read.csv(srcFile, sep = ";")

world_map <- map_data("world")
#Create a base plot with gpplot2
p <- ggplot() + coord_fixed() + xlab("") + ylab("")

#Add map to base plot
base_world_messy <- p + geom_polygon(data=world_map, aes(x=long, y=lat, group=group), 
                               colour="green", fill="light green")

#Strip the map down so it looks super clean (and beautiful!)
cleanup <- 
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), 
        panel.background = element_rect(fill = 'white', colour = 'white'), 
        axis.line = element_line(colour = "white"), legend.position="none",
        axis.ticks=element_blank(), axis.text.x=element_blank(),
        axis.text.y=element_blank())

base_world <- base_world_messy + cleanup

p <- base_world +
  geom_point(data = tbl, 
             aes(x = lon, y = lat), colour="Black", fill="Brown", pch=21, size=5, alpha=I(0.7))			
			
# generate two maps: normal and hi resolution 			
fname <- ("./idximages/world_map.png")
png(filename=fname,width=1600, height=800)
plot(p)
#
fname <- ("./idximages/world_map_hires.png")
png(filename=fname,width=3200, height=1600)
plot(p)
#
dev.off()

# end of R script
#
