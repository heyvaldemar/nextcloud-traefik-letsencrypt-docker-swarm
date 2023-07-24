#!/bin/bash

NEXTCLOUD_BACKUPS_CONTAINER=$(docker ps -aqf "name=nextcloud_backups")

echo "--> All available database backups:"

for entry in $(docker container exec -it $NEXTCLOUD_BACKUPS_CONTAINER sh -c "ls /srv/nextcloud-postgres/backups/")
do
  echo "$entry"
done

echo "--> Copy and paste the backup name from the list above to restore database and press [ENTER]
--> Example: nextcloud-postgres-backup-YYYY-MM-DD_hh-mm.gz"
echo -n "--> "

read SELECTED_DATABASE_BACKUP

echo "--> $SELECTED_DATABASE_BACKUP was selected"

echo "--> Scaling service down..."
docker service scale nextcloud_nextcloud=0

echo "--> Restoring database..."
docker exec -it $NEXTCLOUD_BACKUPS_CONTAINER sh -c 'PGPASSWORD="$(cat $POSTGRES_PASSWORD_FILE)" dropdb -h postgres -p 5432 nextclouddb -U nextclouddbuser \
&& PGPASSWORD="$(cat $POSTGRES_PASSWORD_FILE)" createdb -h postgres -p 5432 nextclouddb -U nextclouddbuser \
&& PGPASSWORD="$(cat $POSTGRES_PASSWORD_FILE)" gunzip -c /srv/nextcloud-postgres/backups/'$SELECTED_DATABASE_BACKUP' | PGPASSWORD=$(cat $POSTGRES_PASSWORD_FILE) psql -h postgres -p 5432 nextclouddb -U nextclouddbuser'
echo "--> Database recovery completed..."

echo "--> Scaling service up..."
docker service scale nextcloud_nextcloud=1
