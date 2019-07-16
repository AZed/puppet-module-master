#!/bin/sh
#
# FILENAME:	backup-mysql-database.sh
# AUTHOR:	Bennett Samowich <bennett.samowich@nasa.gov>
# DATE:		2010-06-21
#
# DESCRIPTION:
#    Simple script to dumpt the contents of MySQL databases.
#   
# USAGE:
#    Databases can be specified at the command-line.  All databases
#    on the server, except for 'information_schema', will be backed
#    up.  Database names are compared against the list of databases
#    on the server to weed out invalid database names.
#
#    Typically this script will be called via cron
#
##############################################################################

### Root path to the MySQL backups
BACKUPROOT="/var/backups/mysql"

### Number of days to keep on hand
RETENTION=3

###################################################
### You should be safe to leave the rest alone. ###
###################################################

### Databases can be specified at the command-line.
DATABASES=$@

### Get the list of databases from the server
DBLIST="$(/usr/bin/mysql --defaults-file=/etc/mysql/debian.cnf -Bse 'SHOW DATABASES;' | egrep -v 'information_schema')"

### If no databases specified, then use the list from the server.
if [ "${DATABASES}" = "" ]
then
   DATABASES=${DBLIST}
fi

### Date stamp for the backup files
DATESTAMP="$(date +%Y%m%d%H%M%S)"

### Backup each database individually
RETCODE=0
for DATABASE in ${DATABASES}
do
   ### Only attempt to back up the database if it exists on the server
   if [ $(echo "${DBLIST}" | grep ${DATABASE}) ]
   then
      echo -n "Backing up ${DATABASE}..."

      ### Make sure the backup directory exists
      BACKUPDIR="${BACKUPROOT}/${DATABASE}"
      if [ ! -d "${BACKUPDIR}" ]
      then
         mkdir -p "${BACKUPDIR}"
         chown -R root.root "${BACKUPDIR}"
         chmod 700 "${BACKUPDIR}"
      fi

      ### Dump the database
      /usr/bin/mysqldump                       \
         --defaults-file=/etc/mysql/debian.cnf \
         --add-drop-database                   \
         --complete-insert                     \
         --create-options                      \
         --add-drop-table                      \
         --disable-keys                        \
         --extended-insert                     \
         --add-locks                           \
         --flush-logs                          \
         --flush-privileges                    \
         --hex-blob                            \
         --lock-all-tables                     \
         --quick                               \
         --set-charset                         \
         --comments                            \
         --databases                           \
         ${DATABASE}                         | \
         gzip -9c > "${BACKUPDIR}/mysqldb_${DATABASE}_${DATESTAMP}.sql.gz"
      echo "done"

      # Nuke old backups after $RETENTION days
      /usr/bin/find "${BACKUPDIR}" 	\
         -type f 			\
         -name '*.sql.gz' 		\
         -mtime +${RETENTION} | xargs rm 2>/dev/null
   else
      echo "ERROR: ${DATABASE} does not exist"
      RETCODE=1
   fi
done
exit "${RETCODE}"
