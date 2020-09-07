#!/bin/bash

# oneline.sh
# to get a file in one line

FILEIN="filename.txt"
fileout="echo -e \""

while read CMD;
do
    fileout="${fileout}${CMD}\n"
done < "$FILEIN"

fileout="${fileout}\""

echo $fileout 

