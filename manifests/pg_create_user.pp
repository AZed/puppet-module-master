#
# define master::pg_create_user
# =============================

# Create a user, but only if the username is not already in the database
#
# This requires Postgres >= 8.1
#

define master::pg_create_user (
    # Parameters
    # ----------

    # ### superuser
    # The user is a superuser?
    $superuser = false,

    # ### createdb
    # The user can create databases?
    $createdb=false,

    # ### createrole
    # The user can create roles?
    $createrole=false,

    # ### password
    # Password hash to assign
    $password=false,

    # ### replication
    # Used for replication?
    $replication=false,
) {
    if $superuser { $supersql = 'SUPERUSER' }
    else { $supersql = 'NOSUPERUSER' }
    if $createdb { $createdbsql = 'CREATEDB' }
    else { $createdbsql = 'NOCREATEDB' }
    if $replication { $replicationsql = 'REPLICATION' }
    else { $replicationsql = '' }
    if $createrole { $createrolesql = 'CREATEROLE' }
    else { $createrolesql = 'NOCREATEROLE' }
    if $password { $passwordsql = "PASSWORD '${password}'" }
    else { $passwordsql = '' }

    exec { "pg_create_user-${title}":
        command => "psql postgres -U postgres -c \"CREATE USER ${title} WITH ${supersql} ${createdbsql} ${replicationsql} ${createrolesql} ${passwordsql}\"",
        path => "/sbin:/usr/sbin:/bin:/usr/bin",
        unless => "psql postgres -U postgres -Atc 'select usename from pg_shadow' | grep -q '^${title}$'",
        require => Service["postgresql"],
    }
}
