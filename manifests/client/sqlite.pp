#
# class master::client::sqlite
#
# Install basic access tools for SQLite databases
#
# See also:
#   master::client::sqlite::gui
#   master::dev::db
#   master::dev::perl::db
#
class master::client::sqlite {
    case $operatingsystem {
        'debian': {
            package { 'sqlite3': }
        }
        'centos','redhat': {
            package { 'sqlite': }
        }
        'sles': {
            package { 'sqlite3': }
        }
        default: {
            fail("SQLite definition not handled for $::operatingsystem")
        }
    }
}
