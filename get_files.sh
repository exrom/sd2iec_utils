#!/bin/bash

SDCARD=../../sdcard


mkdir -p temp
pushd temp

# https://www.c64-wiki.de/wiki/Dateinavigator

mkdir -p cbm-fb
pushd cbm-fb
wget http://commodore.software/downloads/send/29-disk-menus/1140-cbm-filebrowser-v1-6 -O 1140-cbm-filebrowser-v1-6.zip
unzip -o 1140-cbm-filebrowser-v1-6.zip
cp programs/fb64 $SDCARD/
popd

mkdir -p fibr
pushd fibr
wget --no-check-certificate https://p1x3l.net/downloadm/fibr1.0a22.zip
unzip -o fibr1.0a22.zip
cp fibr.prg $SDCARD/
popd 

mkdir -p dracopy
pushd dracopy
wget http://www.mobilefx.de/code/dc10d.d64 
cp dc10d.d64 $SDCARD/dracopy10d.d64
popd

mkdir -p seabrowse
pushd seabrowse
wget http://berlinc64club.de/wp-content/uploads/2016/02/SEABROWSE13c.zip
unzip -o SEABROWSE13c.zip
cp SEABR13c.d64 $SDCARD/seabrowse13c.d64   # should be lower case
popd

mkdir -p fb
pushd fb
wget http://csdb.dk/getinternalfile.php/99148/fb.prg
cp fb.prg $SDCARD/
popd

mkdir -p sd2iecsnoop
pushd sd2iecsnoop
wget --no-check-certificate https://github.com/exrom/sd2iec-snoop/blob/master/sd2iecsnoop.prg?raw=true -O sd2iecsnoop
cp sd2iecsnoop $SDCARD/
popd


# NAV: what is the direct file link? https://www.commodoreserver.com/PublicDiskDetails.asp?DID=6ECE478B3B7042B98AF63068F4BB8E66
# CBM-Command: bad performance

popd
