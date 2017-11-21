#!/bin/bash

# If too many file in folder, calculate sub folder names with beginning letters
#
# input:    array as parameter
# output:   SUBDIRARRAY[]
#
# example for  MAX==4
# no      input       output
# 1       abc         a
# 2       adx         a
# 3       agh         a
# 4       amu         am
# 5       apq         am
# 6       avs         am


function calc_subdirs()
{
    MAXFILES=64         # max number in dir before split
    MYFILES=("${@}")    # input array as parameter

    if [[ ${#MYFILES[@]} -gt $MAXFILES ]]; then
        echo "split folder because number of entries (${#MYFILES[@]}) is bigger than split limit $MAXFILES"
        PARTS=$(expr $(expr ${#MYFILES[@]} / $MAXFILES) + 1)
        BOUND=$(expr ${#MYFILES[@]} / $PARTS)
        #echo "PARTS $PARTS  BOUND $BOUND"
        for ((K=0; K<$PARTS; K++))
        do
            OFFS=$(($(expr $BOUND \* $K)-1)) || true
            #echo "OFFS $OFFS"
            if [[ $OFFS == -1 ]]; then A="---"; else A=${MYFILES[$OFFS]##*/};fi
            B=${MYFILES[$(($OFFS+1))]##*/}
            for J in $(seq 1 99); do
                A_=${A:0:$J}
                STARTDIR=${B:0:$J}
                if [[ $A_ != $STARTDIR ]]; then
                    break
                fi
            done
            #STARTDIR_LASTFOLDER=${STARTDIR##*/}
            for J in $(seq $(($OFFS+1)) ${#MYFILES[@]}); do
                SUBDIRARRAY[$J]=${STARTDIR,,}/
            done
            #echo "last elem group $I   ($OFFS) $A"
            #echo "1st elem next group ($(($OFFS+1))) $B"
            #echo "starting dir next group \"$STARTDIR_LASTFOLDER\""
        done
    else
        echo "do not need to split folder because number of entries (${#MYFILES[@]}) is not bigger than split limit $MAXFILES"
        for J in $(seq 0 ${#MYFILES[@]}); do
            SUBDIRARRAY[$J]=""
        done
    fi
}
