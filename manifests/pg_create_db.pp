#
# define master::pg_create_db
# ===========================
#
# Create a database, but only if the database name is not already in
# use
#
# $encoding defaults to UTF8, which will cause the database to
# automatically recode output to whatever the client declares it
# needs.  If you want no conversion under any circumstances, set
# encoding => SQL_ASCII
#
define master::pg_create_db (
    # Parameters
    # ----------

    # ### owner
    #
    # User that owns the database to be created
    #
    # `owner` must already exist as a Postgres user (make a Require on
    # master::pg_create_user if necessary)
    $owner,

    # ### encoding
    # Text encoding of the database
    $encoding='UTF8'
) {
    exec { "pg_create_db-${title}":
        command => "createdb -U postgres -O ${owner} -E ${encoding} -T template0 ${title}",
        path => '/sbin:/usr/sbin:/bin:/usr/bin',
        unless => "psql -Alt | grep '^${title}[|]'",
        require => Service['postgresql'],
    }
}
