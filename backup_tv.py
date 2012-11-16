#! /usr/bin/env python
import unicodedata
import MySQLdb
import os
import shutil

mysql_con = MySQLdb.connect (host = "localhost",user = "xbmc",passwd = "xbmc",db = "xbmc_video60")

target = "/home/gom/nas/tv/"

def get_show(s):
    file_info = []
    mc = mysql_con.cursor()
    # showname, season no, ep no, path, filename
    mc.execute("select strTitle, c12, c13, c00, strPath, strFilename from episodeview where strTitle=\"%s\" order by strTitle, c12, c13" % s)
    for m in mc:
        path = "%s%s" % (m[4].replace("smb://MEDIA", "/media"), m[5])
        path = path.replace("twotb1", "twoTB1")
        d = {'showname':m[0], 'season':m[1], 'episode':m[2], 'path':path }
        file_info.append(d);
    return file_info

def copy_show(s):
    print "******************* COPYING SHOW: ",s," ******************* "
    for f in get_show(s):
        s = "0" + f['season'] if(int(f['season'])<10) else f['season']
        e = "e0" + f['episode'] if(int(f['episode'])<10) else "e" + f['episode']
        season_dir = "season_" + s
        series_name = str.lower(f['showname'])
        series_name = series_name.replace("::", "")
        series_name = series_name.replace(": ", " ")
        series_name = series_name.replace(":", " ")
        series_name = "".join(ch for ch in series_name if ch not in ["!", "'", ":", "(", ")", ".", ","])
        series_name = series_name.replace("&", "and")
        series_name = series_name.replace(" ", "_") 

        # unicode screws up some shows, convert to latin-1 ascii
        series_name = unicode(series_name, "latin-1")
        unicodedata.normalize('NFKD', series_name).encode('ascii','ignore')
        fileName, fileExtension = os.path.splitext(f['path'])

        ftarget = target + series_name  + "/" + season_dir + "/" + series_name + "_s"+ s + e + fileExtension
        nfo = target + series_name  + "/" + season_dir + "/" + series_name + "_s"+ s + e + ".nfo"

        if not os.path.isdir(target + series_name): 
            print "\tDirectory: ", series_name, " does not exist, creating..."
            os.mkdir(target+series_name)
        
        if not os.path.isdir(target + series_name + "/" + season_dir):
            print "\tDirectory: ", season_dir, " does not exist, creating..."
            os.mkdir(target + series_name + "/" + season_dir)
        
        if os.path.isfile(fileName+".nfo"):
            print "\tCopying ", fileName+".nfo", " to ", nfo
            shutil.copy2(fileName+".nfo", nfo)

        print "\tCopying ", f['path'], " to ", ftarget
        shutil.copy2(f['path'], ftarget)


mc = mysql_con.cursor()
mc.execute("select distinct strTitle from episodeview order by strTitle")
for m in mc:
    copy_show(m[0])
