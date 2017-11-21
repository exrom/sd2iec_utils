# SD2IEC utilities

This is a collection of scripts to prepare the contents of an sd card for the sd2iec floppy drive emulator for C64.

## get_arnold.sh/get_gamebase64.sh

These scripts download large d64 collections from the internet and prepare the content for usage with sd2iec.

* extract zip files into folder
* rename all files and folders to lower case. As the C64 uses the petscii character set, lower case characters are displayed in upper case and upper case are displayed unreadable. And we don't want to press Commodore+Shift all the time.
* if there is more than one d64 file in a game folder, create an autoswap.lst file
* the C64 is quite slow listing directories with many entries. If there are more than 64 entries in a folder, split them up into sub folders.

These scripts are written in bash. If you want to execute them under windows, use cygwin/MinGW or the windows subsystem for linux (wsl) for windows 10

## get_files.sh

Downloads selected d64,prg like file browsers

## to be done

* only include d64 which run on a sd2iec. Programs using 1541 drive code will work only if this particular fast loader is supported by sd2iec. An (automated) way is wanted, to check for compatibility. Unfortunately, there is no sd2iec emulation available on a PC. Maybe one can run d64, observe whether drive code is used (which signature?). Feedback welcome.
* link to remember collection wanted. High quality cracks +  work fine with sd2iec because fastloaders can be disabled.
