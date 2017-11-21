#!/bin/bash
#
# This script downloads d64 images from the web and converts them into a file
# structure, you can put onto your SD card for usage in sd2iec/gamebase_64
#
# 1. sd2iec cannot handle *.zip files -> they have to be extracted into folders containing the d64
#
# 2. a c64 uses petscii character set. ascii code lower case is coverted to upper case,
# ascii upper case is displayed as control characters -> convert all to lower
#
# 3. if there is more than one d64 file in a game folder, create an autoswap.lst file
#
#
# TBD: some zips come with a VERSION.NFO file. Add a C64 executable, that will display these files
# TBD: c64+ieee is flow on folders with many entries. split the folders into smaller ones?


########################################################################################
# download
########################################################################################
# --no-host-directories
# --cut-dirs=3
# --no-verbose
#ftp://arnold.c64.org/pub/alternative-software-libary/
#ftp://arnold.c64.org/pub/collections/
#ftp://arnold.c64.org/pub/games/
#ftp://arnold.c64.org/pub/recent-releases/
time wget --recursive --no-clobber --no-parent --cut-dirs=2 --reject=html --timeout=10 --directory-prefix=dl ftp://arnold.c64.org/pub/games/

########################################################################################
# extract zip archives
########################################################################################
SRC=dl/arnold.c64.org
DST=sdcard/arnold

set -e

source splitdirs.sh

# loop over dirs 0,a,b,c,... skip folders with ' ', skip folders with sd2iec incompatible files
DIRS=$(find $SRC -maxdepth 1 -mindepth 1 -type d | \
    grep -v " "         | \
    grep -v EMULATION   | \
    grep -v jgames      | \
    grep -v Cartridges  | \
    grep -v Originals   | \
    grep -v kgb         )


echo "extracting zip files with d64 from $SRC to $DST"
for DIR in $DIRS
do
    echo "entering folder $DIR"
    BASEDIR=`basename $DIR`
    mapfile -t FILES <<<$(find $DIR/*.zip -maxdepth 1 | grep -v " ")
    calc_subdirs  "${FILES[@]}"     # source splitdirs.sh
    for I in $(seq 0 "$(expr ${#FILES[@]} - 1)")
    do
        if [[ ! -s ${FILES[$I]} ]]; then echo "skipping empty file ${FILES[$I]}"; continue; fi
        FILE=$(basename ${FILES[$I]})

        if [[ $FILE == *Tragic_Youth_Poetry* ]]; then continue; fi # Tragic_Youth_Poetry..zip contains "TRAGIC YOUTH.PRG    "
        if [[ $FILE == *inertiania+hi_dns* ]]; then continue; fi # inertiania+hi_dns.zip has 22 bytes

        if [[ $FILE == *.zip ]]; then
            BASEDIRLC=${BASEDIR,,}
            GAMEDIR=${SUBDIRARRAY[$I]}${FILE%\.zip}
            GAMEDIR=${GAMEDIR,,}            # lower case
            GAMEDIR=${GAMEDIR/_/ }          # replace '_' by ' ' because '_' is shown as the back arrow in petscii
            GAMEDIR=${GAMEDIR%%.}           # remove trailing '.' - folder not deletable on windows othwrwise
            GAMEDIR=${GAMEDIR%%.}           # Vector_Ball...zip
            GAMEDIR=${GAMEDIR%% }           # in case there remains a ' ' from calc_subdirs

            # unzip - skip if extracted folder exists already
            if [[ ! -d "$DST/$BASEDIRLC/$GAMEDIR" ]]; then
                mkdir -p "$DST/$BASEDIRLC/$GAMEDIR"
                echo "unpacking to $DST/$BASEDIRLC/$GAMEDIR from $FILE"
                unzip -q -o -LL $SRC/$BASEDIR/$FILE -d "$DST/$BASEDIRLC/$GAMEDIR"

                pushd "$DST/$BASEDIRLC/$GAMEDIR" >/dev/null
                    #a/Amoeba.Novotrade.NEI+Legend.zip contains a file "amoba.prg           " (yes, with the trailing spaces!) which is not deletable on windows
                    A=$(find . -iname "* "); if [[ "$A" != "" ]]; then mv "$A" $A;fi

                    # create AUTOSWAP.LST
                    NUMBER_OF_D64=$(find *.d64 2>/dev/null | wc -l)
                    if [[ $NUMBER_OF_D64 > 1 ]]; then
                        #echo "multiple d64 in folder $GAMEDIR, creating autoswap file"
                        find *.d64 >autoswap.lst
                    fi
                popd >/dev/null
            fi
        fi
    done
done
