#!/bin/bash

filename="./sig/Attachments/*sig"

for file in $filename
do
	./sigdbchk.sh
done

