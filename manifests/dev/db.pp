#
# master::dev::db
# ===============
#
# Packages related to developing with databases
#

class master::dev::db {
    include master::dev::base

    case $::osfamily {
        'redhat': {
            $db_packages =
            [
                db4-devel,
                gdbm-devel,
                sqlite-devel,
            ]
        }
        'debian': {
            $db_packages =
            [
                'libdb-dev',
                'libgdbm-dev',
                'libsqlite3-dev',
            ]
        }
        default: { $db_packages = [ ] }
    }
    package { $db_packages: ensure => latest }
}
