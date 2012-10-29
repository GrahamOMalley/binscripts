#! /bin/bash
list="\
/home/gom/.flexget \
/home/gom/.tilda \
/home/gom/.screenrc \
/home/gom/.bash* \
/home/gom/.vim* \
/home/gom/.conky* \
/home/gom/.config/autostart \
/home/gom/.config/deluge \
/home/gom/.config/pioneer* \
/home/gom/.xbmc/userdata/*.xml \
/home/gom/bin"
drop="/media/oneTB/backups/conf_backup"
/usr/bin/mysqldump -u root -proot --all-databases | gzip > /media/oneTB/backups/db_backup/database_`/bin/date +%Y-%m-%d`.sql.gz
echo $list | xargs tar zcvf $drop/backup_conf_`/bin/date +%Y-%m-%d`.tar.gz
