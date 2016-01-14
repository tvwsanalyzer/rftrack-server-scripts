#!/bin/bash
# ------------------------------------------------------------
# modify 02/10/2015.
# generate video
#
# convert -delay 5 total/total_[1-9].png total/total_[1-9][0-9].png total/total_[1-9][0-9][0-9].png total/total_[1-9][0-9][0-9][0-9].png total/total_[1-9][0-9][0-9][0-9][0-9].png output.mov 
# convert -delay 5 total/[0-9][0-9][0-9][0-9][0-9][0-9]_frame.png output.mov
ffmpeg -framerate 25 -i ./total/%06d_frame.png -c:v libx264 -profile:v high -crf 20 -pix_fmt yuv420p $1.mp4



