#!/bin/bash
while getopts d:u:p:h:f: option
do
 case "${option}"
 in
 d) database=${OPTARG};;
 u) user=${OPTARG};;
 p) passwd=${OPTARG};;
 h) host=${OPTARG};;
 f) PRJ=$OPTARG;;
 esac
done
date_bckp=`date +"%d-%m-%Y"`
if [ -z "$database" ] || [ -z "$user" ] || [ -z "$passwd" ] || [ -z "$host" ] || [ -z "$PRJ" ]; then
    echo "The correct format is prj_backup.sh -d database -u DB_username -p DB_password -h DB_host -f project"
    else
    echo "Just seat and relax, backup is on the way!"
    mysqldump -u$user -p$passwd -h$host --add-drop-table $database ${PRJ}_blastRESULTS ${PRJ}_MEROPS ${PRJ}_PFAM ${PRJ}_RFAM | gzip > DeNSAS_${PRJ}_${date_bckp}.sql.gz
fi

