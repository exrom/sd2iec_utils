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
time wget --recursive --no-clobber --no-parent --reject=html --no-use-server-timestamps --timeout=10 --directory-prefix=dl ftp://8bitfiles.net/gamebase_64/Games

########################################################################################
# extract zip archives
########################################################################################
SRC=dl/8bitfiles.net/gamebase_64/Games
DST=sdcard/gamebase_64

set -e

source splitdirs.sh

# gamebase_64 has sub dirs a1,a2,b1,b2,b3,... with ~600 file each. But we want one folder with starting letter
echo "copying folder a1+a2 into a, b1+b2+b3 into b,...."
for SRCDIR in $(find $SRC -name "[a-z][0-9]")
do
DSTDIR=${SRCDIR%%[0-9]} 
    echo $DSTDIR $SRCDIR}
    mkdir -p $DSTDIR
    cp -n $SRCDIR/*.zip $DSTDIR
done

# loop over dirs 0,a,b,c,...
DIRS=$(find $SRC -maxdepth 1 -mindepth 1 -name "[a-z]" -type d | \
    grep -v " "          )

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

        # following zips are empty though valid file size !?! wtf...
        if [[ $FILE == *SIXGAMES_14073_01.zip* ]]; then continue; fi
        if [[ $FILE == *SIXGUN_06839_01.zip* ]]; then continue; fi
        if [[ $FILE == *SIX_06838_02.zip* ]]; then continue; fi
        if [[ $FILE == *SI_15582_01.zip* ]]; then continue; fi
        if [[ $FILE == *SJOELBAK_09616_01.zip* ]]; then continue; fi
        if [[ $FILE == *SK8!_22300_01.zip* ]]; then continue; fi
        if [[ $FILE == *SKAEHUGO_06841_01.zip* ]]; then continue; fi
        if [[ $FILE == *SKAEHUGO_23566_01.zip* ]]; then continue; fi
        if [[ $FILE == *SKAKANJE_13750_01.zip* ]]; then continue; fi
        if [[ $FILE == *SKAKMAT!_25926_01.zip* ]]; then continue; fi
        if [[ $FILE == *SKARITE0_06842_01.zip* ]]; then continue; fi
        if [[ $FILE == *SKAT-KAR_25084_01.zip* ]]; then continue; fi
        if [[ $FILE == *SKAT1_06843_01.zip* ]]; then continue; fi
        if [[ $FILE == *SKAT2_06846_01.zip* ]]; then continue; fi
        if [[ $FILE == *SKAT3_06844_01.zip* ]]; then continue; fi
        if [[ $FILE == *SKAT4_06845_01.zip* ]]; then continue; fi
        if [[ $FILE == *SKATEAND_06847_01.zip* ]]; then continue; fi
        if [[ $FILE == *SKATEBAL_06851_02.zip* ]]; then continue; fi
        if [[ $FILE == *SKATEBOA_06853_01.zip* ]]; then continue; fi
        if [[ $FILE == *SKATEBOB_16266_01.zip* ]]; then continue; fi
        if [[ $FILE == *SKATEBRD_23120_01.zip* ]]; then continue; fi
        if [[ $FILE == *SKATECR0_06848_01.zip* ]]; then continue; fi
        if [[ $FILE == *SKATEJOU_06852_01.zip* ]]; then continue; fi
        if [[ $FILE == *SKATEOD0_06849_02.zip* ]]; then continue; fi
        if [[ $FILE == *SKATERCK_06854_01.zip* ]]; then continue; fi
        if [[ $FILE == *SKATERCK_06854_02.zip* ]]; then continue; fi
        if [[ $FILE == *SKATESAM_13535_01.zip* ]]; then continue; fi
        if [[ $FILE == *SKATEWAR_06855_02.zip* ]]; then continue; fi
        if [[ $FILE == *SKATINGC_14077_01.zip* ]]; then continue; fi
        if [[ $FILE == *SKATIN_06856_01.zip* ]]; then continue; fi

 
        if [[ $FILE == *.zip ]]; then
            BASEDIRLC=${BASEDIR,,}
            GAMEDIR=${SUBDIRARRAY[$I]}${FILE%\.zip}
            GAMEDIR=${GAMEDIR,,}            # lower case
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
