#!/bin/bash

if [ ! "$(docker ps -q -f name=cs-postgres)" ]; then

	# docker container exec -it cs-postgres /bin/bash

	# Backup Docker DB
	docker container exec cs-postgres su postgres -c "pg_dump -Fc chirpstack_as > /var/lib/postgresql/data/chirpstack_as.dump"
	docker container exec cs-postgres su postgres -c "pg_dump -Fc chirpstack_ns > /var/lib/postgresql/data/chirpstack_ns.dump"
	# pg_restore -d chirpstack.as /data/chirpstack.as.dump

fi

