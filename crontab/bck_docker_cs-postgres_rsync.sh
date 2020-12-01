#!/bin/bash


if [ "$(docker ps -q -f name=cs-postgres)" ]; then


	echo "Backup is running"

	# docker container exec -it cs-postgres /bin/bash
	# docker container exec -it cs-postgres su

	# Backup Docker DB
	docker container exec cs-postgres su postgres -c "pg_dump -Fc chirpstack_as > /var/lib/postgresql/data/chirpstack_as.dump"
	docker container exec cs-postgres su postgres -c "pg_dump -Fc chirpstack_ns > /var/lib/postgresql/data/chirpstack_ns.dump"
	# pg_restore -d chirpstack.as /data/chirpstack.as.dump

fi





# Rolling archiving

PathOri="/mnt/VM/docker/chirpstack/postgresqldata/"
PathBackup="/mnt/BackupContainer/"
Container="chirpstack"

dbname="chirpstack_"
dbnameCheck="chirpstack_as.dump"

if [ ! -d $PathBackup$Container ]; then
	mkdir -p $PathBackup$Container
fi


# Copy postgres dump DB
DATE=$(date '+%Y-%m-%d_%Hh_%Mm_%Ss')
EndFile=$(date '+%Y-%m-%d' --date="30 days ago" )

DATEDir=$(date '+%Y-%m')
DATE_REP_del=$(date '+%Y-%m' --date="30 days ago" )

DATEDay=$(date '+%d')
DATE_FILE_del=$(date '+%d' --date="30 days ago" )

echo DATE ${DATEDay}

if [ ! -f ${PathOri}${dbnameCheck} ]; then
	SIZE_SRC="0"
else
	SIZE_SRC=$(ls -l ${PathOri}${dbnameCheck} |head -n1 |awk -F " " '{print $5}')

fi

if [ ! -d $PathBackup$Container/${DATEDir}/${DATEDay}/ ]; then
	mkdir -p  $PathBackup$Container/${DATEDir}/${DATEDay}/	
	SIZE_DST="0"
else
	SIZE_DST=$(ls -l --sort=t $PathBackup$Container/${DATEDir}/${DATEDay}/ |grep $dbname |head -n1 |awk -F " " '{print $5}')
fi



echo "-->SRC $SIZE_SRC<--";
echo "-->DEST $SIZE_DST<--";

if [ "$SIZE_DST" != "$SIZE_SRC" ]; then
        # thingsboard
	apt-get update 
	PKG_OK=$(dpkg-query -W --showformat='${Status}\n' rsync |grep "install ok installed")
	echo Checking for somelib: $PKG_OK

	if [ "" == "$PKG_OK" ]; then
		  echo "No somelib. Setting up somelib."
		  apt-get --force-yes --yes install rsync
	fi

	if [ ! -d "${PathBackup}${Container}/${DATEDir}/${DATEDay}" ]; then
		mkdir -p ${PathBackup}${Container}/${DATEDir}/${DATEDay}
	fi

	if [ -d "${PathBackup}${Container}/${DATE_REP_del}/${DATE_FILE_del}/" ]; then
		rm ${PathBackup}${Container}/${DATE_REP_del}/${DATE_FILE_del}/thingsboard_${EndFile}*
		rmdir ${PathBackup}${Container}/${DATE_REP_del}/${DATE_FILE_del}
	else 
		echo "Directory  ${PathBackup}${Container}/${DATE_REP_del}/${DATE_FILE_del}/ not exist for cleaning"
	fi


	rsync  ${PathOri}/${dbname}*.dump  ${PathBackup}${Container}/${DATEDir}/${DATEDay}/${dbname}${DATE}

	echo "Rsync done "
	echo 	

else 
	echo "Same file"
fi

