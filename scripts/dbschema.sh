#!/bin/bash
# ------------------------------------------------------------
# Script to get schema sql of sqlite db
#
# ------------------------------------------------------------
#
# http://www.sqlite.org/sessions/sqlite.html
# Querying the SQLITE_MASTER table
# 
# select * from sqlite_master;

# get only the sql command to create tables
#
sqlite3 $1 "select sql from sqlite_master;"
