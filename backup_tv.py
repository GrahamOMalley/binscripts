#! /usr/bin/env python
import MySQLdb
import os
import shutil
import gomXBMCTools
import re
import argparse

from datetime import datetime
startTime = datetime.now()

parser = argparse.ArgumentParser(description='Backs up shows from the xbmc library to a new tv directory, renaming and organising files and creating sane tvshow/season/episode dir structure')
parser.add_argument('-a', '--all',  action="store_true", default=False, help='Copy ALL shows')
parser.add_argument('-s', '--show', type=str, required=False, help='The shows name')
parser.add_argument('-t', '--target', type=str, required=False, default='/home/gom/nas/tv/', help='Target directory')
parser.add_argument('--test',  action="store_true", default=False, help='Don\'t actually copy episodes, just create empty file')
parser.add_argument('-v', '--verbose',  action="store_true", default=False, help='Verbose output')
parser.add_argument('-m', '--metadata',  action="store_true", default=False, help='Also copy xbmc metadata')
args = parser.parse_args()
# normalise target
args.target = os.path.normpath(args.target)
args.target += "/"

mysql_con = MySQLdb.connect (host = "localhost",user = "xbmc",passwd = "xbmc",db = "xbmc_video60")

# tv root dirs
tv_root_dirs = ["/media/tv2/", "/media/twoTB1/videos/tv/", "/media/twoTB1/videos/anime"]
xbmc_metadata = ["folder.jpg", "tvshow.nfo", "fanart.jpg"]

def makeFile(file_name):
    """
        makeFile(file_name): makes a file.
    """
    file = open(file_name, 'w')
    file.write('')
    file.close()

def getShow(s):
    """
        getShow(s): returns pathing info for a show in xbmc library
    """
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

def createDirIfNotExist(dir):
    """
        createDirIfNotExist(dir)
    """
    if not os.path.isdir(dir): 
        print "\tDirectory: ", dir, " does not exist, creating..."
        os.mkdir(dir)

def getShowRootPath(filename):
    """
        getShowRootPath(filename): returns path of show based on target dir and filename
    """
    show_root = os.path.relpath(filename, args.target)
    for rdir in tv_root_dirs:
        if rdir in filename:
            base = re.sub(rdir, '', filename)
            regex = re.compile("(.*?)\s*/")
            base_dir = regex.findall(base)[0]
            return rdir + base_dir
            
    print show_root

def copyShow(show):
    """
        copyShow(show): copies single show from xbmc library to destination
    """
    print ""
    print "******************* COPYING SHOW: ",show," ******************* "
    prev_path = ''
    show_dirs = []
    for f in getShow(show):
        # get nice str repr for season/eps
        s = "0" + f['season'] if(int(f['season'])<10) else f['season']
        e = "e0" + f['episode'] if(int(f['episode'])<10) else "e" + f['episode']

        if(prev_path == f['path']):
            if args.verbose:
                print "\t\t\tduplicate: ", f['path']
            continue

        # need to handle joined episodes like show_s01e02e03.avi
        is_multi_episode = re.compile("e[0-9][0-9]e[0-9][0-9]*")
        eps = is_multi_episode.findall(f['path'])
        if(len(eps) > 0):
            e_count = re.compile("e[0-9][0-9]")
            eps = e_count.findall(f['path'])
            prev_path = f['path']
            for i in range(len(eps)-1):
                epno = int(f['episode']) + i + 1
                e += "e0" + str(epno) if(epno < 10) else "e" + str(epno)

        # build up the filename we are copying to
        season_dir = "season_" + s
        series_name = gomXBMCTools.normaliseTVShowName(f['showname'])

        fileName, fileExtension = os.path.splitext(f['path'])
        ftarget = args.target + series_name  + "/" + season_dir + "/" + series_name + "_s"+ s + e + fileExtension
        nfo = args.target + series_name  + "/" + season_dir + "/" + series_name + "_s"+ s + e + ".nfo"

        # create dirs if they don't exist 
        createDirIfNotExist(args.target + series_name)
        createDirIfNotExist(args.target + series_name + os.path.sep + season_dir)

        if args.test:
            print "\t\tCreating empty ", f['path'], " at ", ftarget
            makeFile(ftarget)
        else:
            if(os.path.exists(ftarget)):
               print "\t\tSkipping file ", ftarget, " as it already exists..."
            else:
                print "\t\tCopying ", f['path'], " to ", ftarget
                shutil.copy2(f['path'], ftarget)

        if args.metadata:
            # Copy episode.nfo
            if os.path.isfile(fileName+".nfo"):
                #print "\tCopying ", fileName+".nfo", " to ", nfo
                shutil.copy2(fileName+".nfo", nfo)

            # Copy any tbn/nfo/fanart etc
            show_root = getShowRootPath(f['path'])
            if ((show_root not in show_dirs) and show_root):
                print "\t\tDiscovered show root dir: ", show_root
                show_dirs.append(show_root)
                # copy any .nfo/tbn/etc files
                try:
                    tbns = [f for f in os.listdir(show_root) if re.match(r'season.*.tbn', f)]
                except:
                    tbns = []

                tbns += xbmc_metadata
                tbns.sort()
                for file in tbns:
                    if os.path.exists(show_root + os.path.sep + str(file)):
                        print "\t\t\tFound ", file, ", copying to ", args.target, series_name
                        shutil.copy2(show_root + os.path.sep + file, args.target + series_name)
                print ""

def copyAll():
    """
        copyAll(): copies EVERYTHING from xbmc tv show library
    """
    mc = mysql_con.cursor()
    #mc.execute("select distinct strTitle from episodeview order by strTitle limit 25")
    mc.execute("select distinct strTitle from episodeview order by strTitle")
    for m in mc:
        copyShow(m[0])

if __name__ == "__main__":
    print "Script started at: ", startTime
    if args.all:
        copyAll()
    elif args.show:
        copyShow(args.show)
    else:
        parser.parse_args(["-h"])
    
    print "Script took: ", datetime.now()-startTime


