#!/bin/bash
# ------------------------------------------------------------
# This script compile a c program for sqlite
# Author: Marco Rainone
# Ver. 1.2, 2015/10/20
#
if [ "$#" -ne 1 ]; then
    echo "--------------------------------------------------------------------------------------"
    echo "Illegal number of parameters"
	echo "This script compile a c program for sqlite."
    echo "Use: $0 <name_program>"
	echo "example:"
	echo "$0 opendb"
	echo "compile opendb.c and generate opendb program"
    echo "--------------------------------------------------------------------------------------"
	echo ""
	exit 1
fi
# gcc -o $1 $1.c -lsqlite3 -std=c99
# for popen warning compile, use gnu99
# -lm for ceil
gcc -o $1 $1.c -lm -lsqlite3 -std=gnu99
chmod +x $1
