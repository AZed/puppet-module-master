#
# class master::client::sqlite::gui
#
# Install GUI tools to manage SQLite databases
#
# This automatically includes master::client::sqlite
#
class master::client::sqlite::gui {
    include master::client::sqlite

    case $operatingsystem {
        'debian': {
            package { 'sqlitebrowser': }
        }
        default: {
            fail("SQLite GUI not available for $::operatingsystem")
        }
    }
}
