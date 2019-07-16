# Functions related to database management
# Primarily PostgreSQL and MySQL
# This file should be sourced, not executed
#
# Makes use of timekeeping functions in timefunctions.sh
#
# Copyright 2008-2013 Zed Pobre <zed@resonant.org>
# Licensed to the public under the terms of the GNU GPL version 2
#

function myd {
# MySQL-DebianRoot
# Passwordless MySQL access on Debian systems
# Only works if you have root access
# (specifically, access to /etc/mysql/debian.cnf)
#
    mysql --defaults-file=/etc/mysql/debian.cnf "$@"
}

function myde {
# MySQL-DebianRoot-Execute
# Passwordless execution of MySQL commands on Debian systems
# Only works if you have root access
# (specifically, access to /etc/mysql/debian.cnf)
#
# The command to be executed must be contained in quotes
# e.g.: myde "show databases"
#
    mysql --defaults-file=/etc/mysql/debian.cnf -e "$@"
}

function mydump {
# MySQL-DebianRoot-Dump
# Passwordless execution of mysqldump on Debian systems
# Only works if you have root access
# (specifically, access to /etc/mysql/debian.cnf)
#
    mysqldump --defaults-file=/etc/mysql/debian.cnf "$@"
}

function pg_admins {
    psql postgres -Atc "select usename from pg_user where usesuper='t'" "$@"
}

function pg_grant_all_tables {
# Usage: pg_grant_all_tables <dbname> <grantlist> <userlist> <filter>
#
# Grants the specified comma-delimited grantlist permissions to the
# speficied comma-delimited userlist on all tables in the specified
# database.
#
# If <filter> ($4) is specified, this will be used as a grep filter to
# limit the tables affected.
#
# Using this function will be exceedingly annoying if you cannot
# access the database without a password on your current account, as
# you cannot pass any arguments to psql for the grants.
    if [ X"$4" = "X" ] ; then
        for table in $(pgschematables $1) ; do
            echo "GRANT $2 ON TABLE $table to $3;"
            echo "GRANT $2 ON TABLE $table to $3;" | psql $1
        done
    else
        for table in $(pgschematables $1 | grep $4) ; do
            echo "GRANT $2 ON TABLE $table to $3;"
            echo "GRANT $2 ON TABLE $table to $3;" | psql $1
        done
    fi
}

function pg_users {
    psql postgres -Atc 'select usename from pg_user' "$@"
}

function pgback {
    if [ X"$1" = "X" ] ; then
        echo "You must specify a database to back up!"
        return 1
    fi

    PGDUMPDIR="."
    if [ X"$2" != "X" ] ; then
        PGDUMPDIR=$2
    fi

    nice pg_dump -cZ9 $1 > $PGDUMPDIR/$1-$(ymdh).sql.gz
}

function pgbackall {
    PGDUMPDIR="."
    if [ X"$2" != "X" ] ; then
        PGDUMPDIR=$1
    fi

    for db in $(pgdbs); do
        echo -n "Dumping $db... "
        nice pg_dump -cZ9 $db > $PGDUMPDIR/$db-$(ymdh).sql.gz
        echo "done."
    done
}

function pgdbs {
# pgdbs: list all Postgres databases except the templates/defaults
# If $1 is specified, list only grep matches for that word
    PGDBFILTER="."
    if [ X"$1" != "X" ] ; then
        PGDBFILTER=$1
    fi
    psql -lat | cut -d' ' -f2 | grep -Ev "^(template[0-9]|postgres)$" | grep ${PGDBFILTER}
}

function pgschematables {
# List all Postgres tables in all schemas, in the schemaname.tablename
# format, in the specified database
# Usage: pgschematables <dbname> [pgoptions]
    echo "SELECT schemaname,relname FROM pg_stat_user_tables;" \
        | psql -At "$@" | tr '|' '.'
}

function pgtables {
# List all Postgres tables in the public schema in the specified database
# Usage: pgtables <dbname> [pgoptions]
    echo "SELECT relname FROM pg_stat_user_tables;" | psql -At "$@"
}
