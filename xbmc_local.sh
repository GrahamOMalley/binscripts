#! /bin/bash

# move the thumbnails dir
rm ~/.xbmc/userdata/Thumbnails
ln -s ~/.xbmc/userdata/backupThumbnails  ~/.xbmc/userdata/Thumbnails

# move the advancedsettings.xml
mv ~/.xbmc/userdata/advancedsettings.xml ~/.xbmc/userdata/badvancedsettings.xml
