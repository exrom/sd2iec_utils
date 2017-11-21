#!/bin/bash
#
# will search all sub folder in a given folder, and create an autoswap.lst file if more than one *.d64 is found
#
# usage:
# create_autoswap.sh folder
#

IFS=$(echo -en "\n\b")  # take folders with ' ' as one entry
for DIR in $(find $1 -type d)
do
    pushd "$DIR" >/dev/null
        # create AUTOSWAP.LST
        NUMBER_OF_D64=$(find *.d64 2>/dev/null | wc -l)
        if [[ $NUMBER_OF_D64 > 1 ]]; then
            echo "multiple d64 in folder $DIR, creating autoswap file"
            find *.d64 >autoswap.lst
        fi
    popd >/dev/null
done
