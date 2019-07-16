#
# define master::pg_drop_user
# ===========================
#
# Drop a user, but only if the username is already in the database
#

define master::pg_drop_user {
    exec { "pg_drop_user-${title}":
        command => "dropuser ${title}",
        path => "/sbin:/usr/sbin:/bin:/usr/bin",
        onlyif => "psql postgres -U postgres -Atc 'select usename from pg_shadow' | grep -q '^${title}$'",
        require => Service["postgresql"],
    }
}
