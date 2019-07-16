#
# define master::pg_create_admin
# ==============================
#
# Shortcut helper define that calls master::pg_create_user to create
# an administrative user with superuser, createdb, and createrole
# privileges

define master::pg_create_admin (
    # Parameters
    # ----------

    # ### password
    # Password hash to assign
    $password=false
){
    master::pg_create_user { $title:
        superuser  => true,
        createdb   => true,
        createrole => true,
        password   => $password,
    }
}
