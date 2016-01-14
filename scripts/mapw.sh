#!/bin/bash
# ------------------------------------------------------------
# This script generate the map world with mapworld.R
# ----------------------------------------------------------------------------
filename=$1

Rscript mapworld.R $filename
