#!/bin/bash

filename="./sig/db/*sig"

for file in $filename
do
	./sigreport.sh
done

