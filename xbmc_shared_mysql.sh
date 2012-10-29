#! /bin/bash

# move the thumbnails dir
rm ~/.xbmc/userdata/Thumbnails
ln -s ~/.xbmc/shared_thumbs  ~/.xbmc/userdata/Thumbnails

# move the advancedsettings.xml
mv ~/.xbmc/userdata/badvancedsettings.xml ~/.xbmc/userdata/advancedsettings.xml
