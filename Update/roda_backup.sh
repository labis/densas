#!/bin/bash

#Set all variables
date_bckp=`date +"%d-%m-%Y"`
DIR="/home/mmbrand/auto_bckp/"
DBSERVER="143.106.4.87"
DBNAME="densas"
DBUSER="annotate"
DBPASS=b10ine0!

data_tables=(`mysql --user=$DBUSER -p$DBPASS -h$DBSERVER -e "SHOW TABLES;" $DBNAME | grep -Ev "(Database|information_schema|performance_schema|Tables_in_)"`)


###########################
#first deal with databases
###########################


if [ ! -d "${DIR}/$DBNAME" ]; then
echo $(date -u) "Cool, a new database! Creating directory"
mkdir ${DIR}/$DBNAME
fi

if [ ! -d "${DIR}/$DBNAME/${date_bckp}" ]; then
echo $(date -u)  "Creating backup directory"
mkdir ${DIR}/$DBNAME/${date_bckp}
fi

echo $(date -u)  "starting the backup database $DBNAME"

cd ${DIR}/$DBNAME/${date_bckp}
for i in "${data_tables[@]}"
do
   :
   echo Backing up $i
   mysqldump -u$DBUSER -p$DBPASS -h$DBSERVER --add-drop-table $DBNAME $i > ${i}_${date_bckp}_$DBNAME.sql
   gzip ${i}_${date_bckp}_$DBNAME.sql &
   # do whatever on $i
done
echo $(date -u) "Compressing files"
wait
#Delete older files
find ${DIR}/$DBNAME/* -type d -ctime +180 | xargs ls -alh
