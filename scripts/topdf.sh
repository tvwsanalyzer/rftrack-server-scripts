#!/bin/bash
# ------------------------------------------------------------
# This script convert an html to pdf file
# Author: Marco Rainone
# Ver. 1.0, 2015/12/11
# from:
#
#
# wkhtmltopdf $1.html $2.pdf
# for server linux:
# call wkhtmltopdf with xvfb-run:
xvfb-run wkhtmltopdf $1.html $2.pdf
