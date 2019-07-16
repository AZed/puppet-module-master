#
# define master::pg_drop_db
# =========================
#
# Drop a database, but only if it exists
#

define master::pg_drop_db {
    exec { "pg_drop_db-${title}":
        command => "dropdb -U postgres ${title}",
        path => '/sbin:/usr/sbin:/bin:/usr/bin',
        onlyif => "psql -ltA | grep '^${title}[|]'",
        require => Service['postgresql'],
    }
}
